require "concurrent/atomic/count_down_latch"

module Wsdirector
  module Actors
    class Manager < Concurrent::Actor::Context
      def initialize(clients)
        @clients = clients
        @waiting_clients = []

        @finished_clients_size = @clients.size
      end

      def on_message(message)
        case message
        when :run
          @clients.each_with_index do |client, id|
            actor = Client.spawn("client-#{id}", client.dup).tell(:start)
            @waiting_clients << actor if client_has_wait_all?(client)
          end

          @waiting_clients_size = @waiting_clients.size
        when :wait
          @waiting_clients_size -= 1

          if @waiting_clients_size.zero?
            @waiting_clients.each do |child|
              child.tell :synced
            end
          end
        when :finished
          @finished_clients_size.zero?
        when Client::Done
          # message.data.each do |entry|
          #   puts entry
          # end
          # puts "----------------------"

          @finished_clients_size -= 1
        end
      end

      private

      def client_has_wait_all?(client)
        client.find do |action, data|
          action == 'wait_all'
        end
      end
    end
  end
end
