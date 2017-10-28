require 'support'

RSpec.describe Wsdirector do
  before(:all) do
    @server = ::Puma::Server.new(
      LiteCable::Server::Middleware.new(nil, connection_class: Connection),
      ::Puma::Events.strings
    )
    @server.add_tcp_listener "localhost", 3000
    @server.min_threads = 1
    @server.max_threads = 4

    @server_t = Thread.new { @server.run.join }
  end

  after(:all) do
    @server&.stop(true)
    @t&.join
  end

  it "has a version number" do
    expect(Wsdirector::VERSION).not_to be nil
  end

  it "does something useful" do
    runner = Wsdirector::Runner.new("./broadcast.yml")
    runner.call
  end
end
