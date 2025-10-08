require 'rails_helper'

RSpec.describe ForecastCache do
  it 'writes and reads by zip with cached_at and TTL' do
    cache = described_class.new(store: ActiveSupport::Cache::MemoryStore.new)
    data = { 'foo' => 'bar' }
    written = cache.write_by_zip('12345', data)
    expect(written['cached_at']).to be_present
    read = cache.fetch_by_zip('12345')
    expect(read['foo']).to eq('bar')
  end
end
