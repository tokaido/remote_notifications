describe "notifications can be serialized" do
  def serialize(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    event.to_json
  end

  before do
    @events = []
    @notifier = ActiveSupport::Notifications::Fanout.new
    ActiveSupport::Notifications.notifier = @notifier
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
