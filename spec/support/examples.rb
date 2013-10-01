
shared_examples_for "a key value formatter" do
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

  it { should include('method=GET') }
  it { should include('path=/') }
  it { should include('status=200') }
  it { should include('custom=data') }
end
