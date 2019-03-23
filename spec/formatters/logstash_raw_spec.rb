describe Lograge::Formatters::LogstashRaw do
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

  let(:subject_h) { subject.to_hash }

  it { is_expected.to be_a LogStash::Event }

  it "includes the 'message' key/value" do
    expect(subject_h['message']).to eq('[200] GET / (welcome#index)')
  end

  it "includes the 'custom' key/value" do
    expect(subject_h[:custom]).to eq('data')
  end

  it "includes the 'status' key/value" do
    expect(subject_h[:status]).to eq(200)
  end

  it "includes the 'method' key/value" do
    expect(subject_h[:method]).to eq('GET')
  end

  it "includes the 'path' key/value" do
    expect(subject_h[:path]).to eq('/')
  end

  it "includes the 'controller' key/value" do
    expect(subject_h[:controller]).to eq('welcome')
  end

  it "includes the 'action' key/value" do
    expect(subject_h[:action]).to eq('index')
  end
end
