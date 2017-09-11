require 'logger'

describe DomainEventProcessor do
  let(:event_name) { 'domain_event.one' }
  let(:event_serialized) { 'event serialized' }
  let(:event_deserialized) { { name: event_name } }

  before(:each) do
    @domain_event_listener = instance_spy(DomainEventListener)
    @serializer = instance_spy(Serializer)
    @logger = instance_spy(Logger)
    @domain_event_processor = DomainEventProcessor.new(
      @domain_event_listener,
      @serializer,
      @logger
    )

    @subscriber = instance_spy(DomainEventSubscriber)
    @domain_event_processor << @subscriber

    allow(@domain_event_listener).to \
      receive(:listen).and_yield(event_serialized)

    allow(@serializer).to receive(:deserialize)\
      .with(event_serialized).and_return(event_deserialized)
  end

  context 'when event name matches' do
    before(:each) do
      allow(@subscriber).to receive(:domain_event_name).and_return(event_name)

      @domain_event_processor.listen_and_process_events
    end

    it 'routes events to subscribers' do
      expect(@subscriber).to have_received(:process).with(event_deserialized)
    end

    it 'logs event' do
      message = ''
      expect(@logger).to have_received(:info) { |args| message = args }

      expect(message).to \
        eq("#{@subscriber.class} processes domain event " \
           "with payload: #{event_deserialized}")
    end

    context 'and event subscriber raises an error' do
      before(:each) do
        @exception = RuntimeError.new
        allow(@subscriber).to receive(:process).and_raise(@exception)
      end

      it 'is captured and logged' do
        @domain_event_processor.listen_and_process_events

        expect(@logger).to have_received(:error).with(@exception)
      end
    end
  end

  context 'when event name does not match' do
    it 'does not dispatch events to subscriber' do
      allow(@subscriber).to \
        receive(:domain_event_name).and_return('domain_event.other')
      @domain_event_processor.listen_and_process_events

      expect(@subscriber).not_to \
        have_received(:process).with(event_deserialized)
    end
  end
end
