require 'pubsub/version'
require 'pubsub/serializer'
require 'pubsub/domain_event_processor'
require 'pubsub/multithreaded_domain_event_processor'

module Pubsub
  class DomainEventPublisher
    def publish(_event)
      raise NotImplementedError
    end
  end

  class DomainEventListener
    def listen(&_block)
      raise NotImplementedError
    end
  end

  class DomainEventSubscriber
    def domain_event_name
      raise NotImplementedError
    end

    def process(_domain_event)
      raise NotImplementedError
    end
  end
end
