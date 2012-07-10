require "active_support"
require "active_support/json"
require "active_support/notifications"
require "remote_notifications/version"

module ActiveSupport
  module Notifications
    class Event
      def self.from_json(json)
        object = ActiveSupport::JSON.decode(json)

        name, start, finish, id, payload =
          object.values_at("name", "time", "end", "transaction_id", "payload")

        start = DateTime.parse(start)
        finish = DateTime.parse(finish)

        new(name, start, finish, id, payload)
      end
    end
  end
end
