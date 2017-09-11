module Pubsub
  class MultiThreadedDomainEventProcessor < DomainEventProcessor
    def initialize(domain_event_listener, serializer, logger)
      super(domain_event_listener, serializer, logger)
      amount_of_threads = Concurrent.processor_count
      @thread_pool = Concurrent::FixedThreadPool.new(amount_of_threads)
    end

    protected

    def broadcast(message)
      domain_event = @serializer.deserialize(message)

      @subscribers.each do |subscriber|
        @thread_pool.post do
          if handles_event?(domain_event, subscriber)
            process_event_for(subscriber, domain_event)
          end
        end
      end
    end
  end
end
