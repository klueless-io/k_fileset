# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KFileset::GlobInfo do
  subject { instance }

  let(:pwd) { Dir.pwd }

  let(:instance) { described_class.new(glob, exclude) }
  let(:glob) { '*' }
  let(:exclude) { nil }

  describe '#initialize' do
    it { is_expected.to be_a(KFileset::GlobInfo) }

    context 'when normalizing paths and globs' do
      context 'when glob *.*' do
        let(:glob)  { '*.*' }
        it do
          is_expected.to have_attributes(
            working_directory: pwd,
            glob: '*.*'
          )
        end
      end

      context 'when glob some_path/*' do
        let(:glob)  { 'some_path/*' }
        it do
          is_expected.to have_attributes(
            working_directory: pwd,
            glob: 'some_path/*'
          )
        end
      end

      context 'when glob some_path/**/' do
        let(:glob)  { 'some_path/**/' }
        it do
          is_expected.to have_attributes(
            working_directory: pwd,
            glob: 'some_path/**/'
          )
        end
      end

      context 'when glob some_path/*.*' do
        let(:glob)  { 'some_path/*.*' }
        it do
          is_expected.to have_attributes(
            working_directory: pwd,
            glob: 'some_path/*.*'
          )
        end
      end

      context 'when glob ../*.*' do
        let(:glob)  { '../*.*' }
        it do
          is_expected.to have_attributes(
            working_directory: pwd,
            glob: '../*.*'
          )
        end
      end

      context 'when glob ./*.*' do
        let(:glob)  { './*.*' }
        it do
          is_expected.to have_attributes(
            working_directory: pwd,
            glob: '*.*'
          )
        end
      end

      context 'when glob spec/k_manager/../../k_manager/spec/../what_*.tf' do
        let(:glob)  { 'spec/k_manager/../../spec/../what_*.tf' }
        it do
          is_expected.to have_attributes(
            working_directory: pwd,
            glob: 'what_*.tf'
          )
        end
      end

      context 'when glob xmen/**/bob/**/*.the_builder' do
        let(:glob)  { 'xmen/**/bob/**/*.the_builder' }
        it do
          is_expected.to have_attributes(
            working_directory: pwd,
            glob: 'xmen/**/bob/**/*.the_builder'
          )
        end
      end
    end

    context '.exclusions' do
      subject { instance.exclusions }

      context 'when exclusion is nil' do
        let(:exclude) { nil }

        it { is_expected.to be_empty }
      end

      context 'when exclusion is []' do
        let(:exclude) { [] }

        it { is_expected.to be_empty }
      end

      context 'when single Glob based exclusion' do
        let(:exclude) { '*.*' }

        it { is_expected.to eq(['*.*']) }
      end

      context 'when single RegExp based exclusion' do
        let(:exclude) { /xmen?/ }

        it { is_expected.to eq([/xmen?/]) }
      end

      context 'when single lambda exclusion' do
        let(:exclude) { ->(f) { f } }

        it { is_expected.to include(->(f) { f }) }
      end

      context 'when mixed Glob, RegExp and lambda exclusions' do
        let(:exclude) { ['*.*', /xmen?/, '**/*.wtf', ->(f) { f }] }

        it { is_expected.to have_attributes(length: 4) }
      end
    end
  end

  context '.entry' do
    subject { instance.entry }

    let(:instance) { described_class.new(glob, exclude) }
    let(:glob) { '*.*' }
    let(:exclude) { '*.wtf' }

    it { is_expected.to be_a(KFileset::GlobEntry) }

    it do
      is_expected.to have_attributes(
        working_directory: pwd,
        glob: '*.*',
        exclusions: ['*.wtf']
      )
    end
  end
end
