require "active_support"
require "active_support/json"
require "active_support/notifications"
require "remote_notifications/version"

unless defined?(ActiveSupport::Notifications::Subscribers::Timed)
  require "remote_notifications/backport"
end

module ActiveSupport
  module Notifications
    class Event
      def self.from_json(json)
        object = ActiveSupport::JSON.decode(json)

        name, start, finish, id, payload =
          object.values_at("name", "time", "end", "transaction_id", "payload")

        # Older versions of Rails return a DateTime here
        if start.is_a?(String)
          start = DateTime.parse(start)
          finish = DateTime.parse(finish)
        else
          start = start.to_datetime
          finish = finish.to_datetime
        end

        new(name, start, finish, id, payload)
      end
    end
  end
end

class RemoteNotifier
  def start(name, id, payload)
    serialized = serialize(name, id, Time.now, payload)
    dispatch "before", serialized
  end

  def finish(name, id, payload)
    serialized = serialize(name, id, Time.now, payload)
    dispatch "after", serialized
  end
end

class RemoteSubscriber
  def process(blob)
    sequence, name, id, payload = deserialize(blob)
    notifier = ActiveSupport::Notifications.notifier

    notifier.send(sequence, name, id, payload)
  end
end
