require 'puma'
require 'litecable'
require 'lite_cable/server'

class Connection < LiteCable::Connection::Base
  identified_by :user, :sid

  def connect
  end

  def disconnect
  end
end

class TestChannel < LiteCable::Channel::Base
  identifier 'TestChannel'

  def subscribed
    stream_from "all"
  end

  def echo(data)
    transmit data
  end

  def broadcast(data)
    LiteCable.broadcast "all", data
  end
end
