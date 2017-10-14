module Wsdirector
  class Message
    attr_reader :data

    def initialize(data)
      @data = data
    end
  end
end
