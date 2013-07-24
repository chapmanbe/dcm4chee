require 'spec_helper'

describe RemotePackage do
  let(:node) do
    {
      :dcm4chee => {
        #TODO: Rename to 'packages' or 'remote_packages'!
        :source => {
          :foo  => {
            :source => 'http://www.example.com/foo.zip',
            :checksum => 'deadbeef'
          }
        }
      }
    }
  end

  let(:pkg) { RemotePackage.new :foo, node }

  describe '#source' do
    it 'returns the source' do
      expect(pkg.source).to eq 'http://www.example.com/foo.zip'
    end
  end

  describe '#checksum' do
    it 'returns the checksum' do
      expect(pkg.checksum).to eq 'deadbeef'
    end
  end

  describe '#destination' do
    it 'returns the destination' do
      expect(pkg.destination).to eq "#{Chef::Config[:file_cache_path]}/foo.zip"
    end
  end

  describe '#basename' do
    context 'when explicitely set' do
      before do
        node[:dcm4chee][:source][:foo][:basename] = 'bar'
      end

      it 'returns the attribute' do
        expect(pkg.basename).to eq 'bar'
      end
    end

    context 'when not set' do
      before do
        node[:dcm4chee][:source][:foo][:basename] = nil
      end

      it 'returns the basename based on the filename' do
        expect(pkg.basename).to eq 'foo'
      end
    end
  end

  describe '#basedir' do
    it 'returns the joined prefix and basename' do
      pkg.stub(:prefix).and_return('/tmp')
      pkg.stub(:basename).and_return('bar')
      expect(pkg.basedir).to eq '/tmp/bar'
    end
  end

  describe '#prefix' do
    before do
      node[:dcm4chee][:prefix] = '/usr/local'
    end

    it 'returns the install prefix' do
      expect(pkg.prefix).to eq '/usr/local'
    end
  end
end
