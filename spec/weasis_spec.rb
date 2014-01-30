require 'spec_helper'

describe 'dcm4chee::weasis' do
  let(:chef_run)         { ChefSpec::ChefRunner.new({:evaluate_guards => true}).converge(described_recipe) }
  let(:prefix)           { '/usr/local' }
  let(:dcm4chee_basedir) { "#{prefix}/dcm4chee-2.17.1-mysql" }

  {
    'weasis.war' => {
      :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/1.2.8/weasis.war',
      :checksum => 'cce33f9d9ec543e1113746e63ffbe154984726946203cfde44711565cfa5e0a7'
    },
    'weasis-i18n.war' => {
      :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/1.2.8/weasis-i18n.war',
      :checksum => '87f4fabf1274664b0e53b583af573d24fc30cf68e7aa094415d131f295813d6c'
    },
    'weasis-pacs-connector.war' => {
      :source => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/weasis-pacs-connector/4.0.0/weasis-pacs-connector.war',
      :checksum => '9e1ff77f4c2edf3fb8204fb9c0f783de3f2ae8d4328dfd2a4cdfd02c7b050d1a'
    },
    'dcm4chee-web-weasis.jar' => {
      :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/weasis-pacs-connector/4.0.0/dcm4chee-web-weasis.jar',
      :checksum => '1ae1419e60ca6eb5b76e999ebc5c9efce8c3351bc80beb99076232b883820ea6'
    }
  }.each_pair do |file,attributes|
    it "deploys #{file}" do
      destination = "#{dcm4chee_basedir}/server/default/deploy/#{file}"
      expect(chef_run).to create_remote_file(destination).with(attributes)
    end
  end
end
