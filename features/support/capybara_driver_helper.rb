module Test
  module Capybara
    class ServerOnly
      def needs_server?
        true
      end

      # rubocop:disable MethodMissing
      def method_missing(*_)
      raise '
          This is a fake driver and should not be used apart from to setup a server.
          If you are trying to visit etc.. you are using the wrong driver
        '
      end
      # rubocop:enable MethodMissing

      def respond_to_missing?(*_)
        true
      end
    end
  end
end
Capybara.register_driver :server_only do |_|
  ::Test::Capybara::ServerOnly.new
end