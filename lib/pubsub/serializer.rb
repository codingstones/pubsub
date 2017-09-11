module Pubsub
  class Serializer
    def serialize(_object)
      raise NotImplementedError
    end

    def deserialize(_raw)
      raise NotImplementedError
    end
  end
end
