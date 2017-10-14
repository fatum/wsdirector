require "yaml"
require "json"

module Wsdirector
  class Runner
    def initialize(file)
      @file = file
    end

    def call
      clients = parse(YAML.load_file(@file))

      manager = Actors::Manager.spawn(:manager, clients)
      manager.ask!(:run)

      loop do
        # puts "[Runner] Check manager for running"

        if manager.ask!(:finished)
          break
        else
          sleep 2
        end
      end
    end

    private

    def parse(schema)
      return [] if schema.size == 0

      if schema.first.has_key?("receive") || schema.first.has_key?("send")
        [schema]
      else
        schema.map { |record| record['client'] }
      end
    end
  end
end
