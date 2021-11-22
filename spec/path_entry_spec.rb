# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KFileset::PathEntry do
  subject { instance }

  let(:instance) { described_class.new(path) }
  let(:path) { 'some_file' }

  describe '#initialize' do
    it { is_expected.not_to be_nil }
  end

  context '.key' do
    subject { instance.key }

    let(:expected_path) { File.expand_path(path) }

    context 'when path matches a real file' do
      let(:path) { 'spec/samples/target/look-at-my-eyes.txt' }

      it { is_expected.to eq(expected_path) }
    end

    context 'when path does not match an existing file' do
      let(:path) { 'spec/samples/target/file-not-found.txt' }

      it { is_expected.to eq(expected_path) }
    end

    context 'when path matches a real folder' do
      let(:path) { 'spec/samples/target' }

      it { is_expected.to eq(expected_path) }
    end

    context 'when path matches a real folder plus DOT' do
      let(:path) { 'spec/samples/target/.' }

      it { is_expected.to eq(File.join(expected_path, '.')) }
    end
  end

  context '.safe_realpath' do
    subject { instance.safe_realpath }

    let(:expected_path) { File.expand_path(path) }

    context 'when path matches a real file' do
      let(:path) { 'spec/samples/target/look-at-my-eyes.txt' }

      it { is_expected.to eq(expected_path) }
    end

    context 'when path does not match an existing file' do
      let(:path) { 'spec/samples/target/file-not-found.txt' }

      it { is_expected.to eq(expected_path) }
    end

    context 'when path matches a real folder' do
      let(:path) { 'spec/samples/target' }

      it { is_expected.to eq(expected_path) }
    end

    context 'when path matches a real folder plus DOT' do
      let(:path) { 'spec/samples/target/.' }

      it { is_expected.to eq(expected_path) }
    end
  end

  context '.uri' do
    subject { instance.uri }

    it { is_expected.not_to be_nil }

    context '.uri.scheme' do
      subject { instance.uri.scheme }
    
      it { is_expected.to eq('file') }
    end

    context '.uri.path' do
      subject { instance.uri.path }
    
      it { is_expected.to eq(File.expand_path(path)) }
    end
  end

  # context 'when path matches a real location' do
  #   let(:path) { 'spec/samples/target/look-at-my-eyes.txt' }

  #   fit { is_expected.to eq }
  #   fit { subject.debug }
  # end

  # context '.uri' do
  #   subject { instance.uri }

  #   fit { is_expected.to be_empty }
  # end
end
