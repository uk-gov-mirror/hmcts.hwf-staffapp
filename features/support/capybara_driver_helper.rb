module Test
  module Capybara
    class ServerOnly
      def needs_server?
        true
      end

      def method_missing(*args)
        raise 'This is a fake driver and should not be used apart from to setup a server.  If you are trying to visit etc.. you are using the wrong driver'
      end
    end
  end
end
Capybara.register_driver :server_only do |app|
  ::Test::Capybara::ServerOnly.new
end