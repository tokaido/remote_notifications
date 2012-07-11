class JSONNotifier < RemoteNotifier
  attr_reader :events

  def initialize(*)
    super
    @events = []
  end

  def serialize(name, id, time, payload)
    {
      :name => name,
      :id => id,
      :time => time,
      :payload => payload
    }.to_json
  end

  def dispatch(time, data)
    @events << [time, data]
  end
end

describe "remote notifications" do
  def serialize(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    event.to_json
  end

  before do
    @events = []
    @notifier = ActiveSupport::Notifications::Fanout.new
    ActiveSupport::Notifications.notifier = @notifier
  end

  describe "notifications can be serialized" do
    before do
      @subscription = @notifier.subscribe do |*args|
        @events << serialize(*args)
      end

      ActiveSupport::Notifications.instrument :ohai, { :payload => true }

      @events.size.should == 1
      @json = @events[0]
      @object = ActiveSupport::JSON.decode(@events[0])
    end

    it "receives the notification" do
      object = ActiveSupport::JSON.decode(@events[0])

      object["name"].should == "ohai"
      object["payload"].should == { "payload" => true }

      object.should have_key("duration")
      object.should have_key("end")
      object.should have_key("time")
      object.should have_key("transaction_id")
    end

    it "can build an event object from the JSON" do
      event = ActiveSupport::Notifications::Event.from_json(@events[0])

      event.name.should == "ohai"
      event.payload.should == { "payload" => true }

      event.duration.should be_kind_of(Numeric)
      event.end.should be_kind_of(DateTime)
      event.time.should be_kind_of(DateTime)
      event.transaction_id.should be_kind_of(String)
    end
  end

  describe "it has a remote notification API" do
    before do
      @test_notifier = JSONNotifier.new
      @subscriber = ActiveSupport::Notifications.subscribe(nil, @test_notifier)
      ActiveSupport::Notifications.instrument :ohai, { :payload => true }

      @test_notifier.events.size.should == 2
    end

    after do
      ActiveSupport::Notifications.unsubscribe @test_notifier
    end

    it "should have received a JSON payload" do
      before, before_data = @test_notifier.events[0]
      after, after_data = @test_notifier.events[1]

      before.should == "before"
      after.should == "after"

      object = ActiveSupport::JSON.decode(before_data)

      object["name"].should == "ohai"
      object["id"].should be_kind_of String
      object["time"].should be_kind_of String
      object["payload"].should == { "payload" => true }


      object = ActiveSupport::JSON.decode(after_data)

      object["name"].should == "ohai"
      object["id"].should be_kind_of String
      object["time"].should be_kind_of String
      object["payload"].should == { "payload" => true }
    end
  end
end
