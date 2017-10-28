require "websocket-client-simple"

module Wsdirector
  module Actors
    class Connection < Concurrent::Actor::Context
      class Send < Message; end

      def initialize(config = {})
        @config = config
      end

      def on_message(message)
        case message
        when :create
          log :actor, "create"
          @ws = create_connection
        when Send
          @ws.send message.data.to_json
        when :stop
          @ws.close if @ws
        end
      end

      def log(action, msg)
        puts "[#{parent.name}][#{name}][#{action}] #{msg}"
      end

      def create_connection
        _ = self

        WebSocket::Client::Simple.connect 'ws://localhost:3000/cable' do |ws|
          ws.on :message do |msg|
            data = JSON.parse(msg.data)

            # p data

            # _.log :websocket, "msg: #{msg.data}"

            if data['type'] == 'ping'
              # _.log :websocket, "pong"
            else
              _.parent.tell(Client::Data.new(data))
            end
          end

          ws.on :open do
            _.log :websocket, "open (#{ws.url})"
            _.parent.tell(:connected)
          end

          ws.on :close do |e|
            _.log :websocket, "close (#{e})"
          end

          ws.on :error do |e|
            _.log :websocket, "error (#{e})"
          end
        end
      end
    end
  end
end
