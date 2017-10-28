require "concurrent/scheduled_task"
require "concurrent/timer_task"

module Wsdirector
  module Actors
    class Client < Concurrent::Actor::Context
      class Done < Message; end
      class Data < Message; end

      def initialize(actions)
        @actions = actions
        @logs = []

        @timer = Concurrent::TimerTask.new(execution_interval: 1, timeout_interval: 1) do |task|
          log "Timeout..."
          task.shutdown

          finish!
        end
      end

      def on_message(message)
        case message
        when :start
          log "Started"
          @connection = Connection.spawn("ws-#{name}", {}).tell(:create)
        when :connected
          log "Connected"
          tell :next
        when :next
          @current_action = @actions.shift

          if @current_action
            process_next_action!
          else
            log "Stopping"
            finish!
          end
        when :synced
          log "Synced"
          tell :next
        when Data
          @message = message.data
          match_message!
        end
      end

      def finish!
        @connection.ask(:stop).then do
          parent.tell(Done.new(@logs))
        end
      end

      def process_next_action!
        case action_id
        when 'receive'
          @timer.execute

          log "Waiting on message #{@current_action.dig('receive', 'data')}"
          match_message!
        when 'send'
          send_message!
        when 'wait_all'
          log "Request synchronization"

          parent.tell :wait
        end
      end

      def send_message!
        data = @current_action.dig('send', 'data')
        log "Send message #{data}"

        @connection.tell(Connection::Send.new(data))

        @message = nil
        tell :next
      end

      def match_message!
        if synced? && @current_action['receive']
          (cleanup_current_action == @message).tap do |matched|
            if matched
              log "Matched"
            else
              log "Don't matched #{@message}"
            end

            tell :next
            @timer.shutdown

            @message = nil
          end
        end
      end

      def synced?
        @current_action && @message
      end

      def action_id
        @current_action.instance_of?(Hash) ? @current_action.keys.first : @current_action
      end

      def cleanup_current_action
        @current_action.dig('receive', 'data').tap do |data|
          data['message'] = JSON.parse(data['message']) if data['message']
        end
      end

      def log(msg)
        entry = "[#{name}] #{Time.now.to_i} #{msg}"
        puts entry

        @logs << entry
      end
    end
  end
end
