describe Lograge::Formatters::Logstash do
  let(:payload) do
    {
      custom: 'data',
      status: 200,
      method: 'GET',
      path: '/',
      controller: 'welcome',
      action: 'index'
    }
  end

  subject { described_class.new.call(payload) }

  it "includes the 'message' key/value" do
    expect(subject).to match(%r{"message":"\[200\] GET \/ \(welcome#index\)"})
  end

  it "includes the 'custom' key/value" do
    expect(subject).to match(/"custom":"data"/)
  end

  it "includes the 'status' key/value" do
    expect(subject).to match(/"status":200/)
  end

  it "includes the 'method' key/value" do
    expect(subject).to match(/"method":"GET"/)
  end

  it "includes the 'path' key/value" do
    expect(subject).to match(%r{"path":"/"})
  end

  it "includes the 'controller' key/value" do
    expect(subject).to match(/"controller":"welcome"/)
  end

  it "includes the 'action' key/value" do
    expect(subject).to match(/"action":"index"/)
  end
end
