module Pubsub
  class DomainEventProcessor
    def initialize(domain_event_listener, serializer, logger)
      @domain_event_listener = domain_event_listener
      @serializer = serializer
      @logger = logger
      @subscribers = []
    end

    def <<(subscriber)
      @subscribers << subscriber
    end

    def listen_and_process_events
      @domain_event_listener.listen do |message|
        broadcast(message)
      end
    end

    protected

    def broadcast(message)
      domain_event = @serializer.deserialize(message)

      @subscribers.each do |subscriber|
        if handles_event?(domain_event, subscriber)
          process_event_for(subscriber, domain_event)
        end
      end
    end

    def handles_event?(domain_event, subscriber)
      domain_event[:name] == subscriber.domain_event_name
    end

    def process_event_for(subscriber, domain_event)
      @logger.info("#{subscriber.class} processes domain event with " \
                   "payload: #{domain_event}")
      subscriber.process(domain_event)
    rescue StandardError => error
      @logger.error(error)
    end
  end
end
