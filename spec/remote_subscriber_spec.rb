require "date"

class JSONSubscriber < RemoteSubscriber
  def deserialize(blob)
    payload = ActiveSupport::JSON.decode(blob)
    return payload["sequence"], payload["name"], payload["id"], payload["payload"]
  end
end

describe "the remote subscriber" do
  before do
    @test_subscriber = JSONSubscriber.new
    @notifier = ActiveSupport::Notifications::Fanout.new
    @events = []

    ActiveSupport::Notifications.notifier = @notifier
    ActiveSupport::Notifications.subscribe do |*args|
      @events << ActiveSupport::Notifications::Event.new(*args)
    end
  end

  it "deserializes a remote notification" do
    @test_subscriber.process ActiveSupport::JSON.encode(:sequence => :start, :name => "ohai", :id => "abc123def", :payload => { :ohai => true })
    @test_subscriber.process ActiveSupport::JSON.encode(:sequence => :finish, :name => "ohai", :id => "abc123def", :payload => { :ohai => true })

    @events.size.should == 1

    event = @events[0]

    event.name.should == "ohai"
    event.transaction_id.should == "abc123def"
    event.payload.should == { "ohai" => true }
  end
end
