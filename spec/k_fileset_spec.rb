# frozen_string_literal: true

RSpec.describe KFileset do
  it 'has a version number' do
    expect(KFileset::VERSION).not_to be nil
  end

  it 'has a standard error' do
    expect { raise KFileset::Error, 'some message' }
      .to raise_error('some message')
  end
end
