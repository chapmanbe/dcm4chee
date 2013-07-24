require 'spec_helper'

describe 'dcm4chee::default' do
  let(:chef_run) { ChefSpec::ChefRunner.new({:evaluate_guards => true}) }
  let(:tmp) { Chef::Config[:file_cache_path] }
  let(:prefix) { '/usr/local' }
  before(:each) { ::File.stub(:exists?).and_call_original }

  def converge!
    chef_run.converge 'dcm4chee::default'
  end

  it 'installs unzip' do
    converge!
    expect(chef_run).to install_package('unzip')
  end

  it 'downloads dcm4chee when the basedir is missing' do
    File.should_receive(:exists?).with('/usr/local/dcm4chee-2.17.1-mysql').and_return(false)
    converge!
    expect(chef_run).to create_remote_file("#{tmp}/dcm4chee-2.17.1-mysql.zip").with(
      :source => 'http://downloads.sourceforge.net/project/dcm4che/dcm4chee/2.17.1/dcm4chee-2.17.1-mysql.zip',
      :checksum => '7597cf96620c58edf4a00499adbcd8f26a78c3c5127ebfa8567810bb0dc737b6'
    )
  end

  it 'does not download dcm4chee when the basedir is present' do
    File.should_receive(:exists?).with('/usr/local/dcm4chee-2.17.1-mysql').and_return(true)
    converge!
    expect(chef_run).to_not create_remote_file("#{tmp}/dcm4chee-2.17.1-mysql.zip")
  end

  it 'unpacks dcm4chee' do
    converge!
    expect(chef_run).to execute_command("unzip #{tmp}/dcm4chee-2.17.1-mysql.zip").with(
      :cwd => "/usr/local",
      :creates => "/usr/local/dcm4chee-2.17.1-mysql"
    )
  end

  it 'downloads jboss when the basedir is missing' do
    File.should_receive(:exists?).with('/usr/local/jboss-4.2.3.GA').and_return(false)
    converge!
    expect(chef_run).to create_remote_file("#{tmp}/jboss-4.2.3.GA.zip").with(
      :source => 'http://downloads.sourceforge.net/project/jboss/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA.zip',
      :checksum => 'a5d518286dae6ea432a6f7a5506c2338ad1751ae4b6d7ce2082436b2d3f87f46'
    )
  end

  it 'does not download jboss when the basedir is present' do
    File.should_receive(:exists?).with('/usr/local/jboss-4.2.3.GA').and_return(true)
    converge!
    expect(chef_run).to_not create_remote_file("#{tmp}/jboss-4.2.3.GA.zip")
  end

  it 'unpacks jboss' do
    converge!
    expect(chef_run).to execute_command("unzip #{tmp}/jboss-4.2.3.GA.zip").with(
      :cwd => prefix,
      :creates => "#{prefix}/jboss-4.2.3.GA"
    )
  end

  it 'downloads dcm4chee-arr when the basedir is missing' do
    File.should_receive(:exists?).with('/usr/local/dcm4chee-arr-3.0.11-mysql').and_return(false)
    converge!
    expect(chef_run).to create_remote_file("#{tmp}/dcm4chee-arr-3.0.11-mysql.zip").with(
      :source => 'http://downloads.sourceforge.net/project/dcm4che/dcm4chee-arr/3.0.11/dcm4chee-arr-3.0.11-mysql.zip',
      :checksum => '3de87af391d127b04da8000a1398622283cbb0dc4ffa4a769d8d45a106b43f94'
    )
  end

  it 'does not download dcm4chee-arr when the basedir is present' do
    File.should_receive(:exists?).with('/usr/local/dcm4chee-arr-3.0.11-mysql').and_return(true)
    converge!
    expect(chef_run).to_not create_remote_file("#{tmp}/dcm4chee-arr-3.0.11-mysql.zip")
  end

  it 'unpacks jboss' do
    converge!
    expect(chef_run).to execute_command("unzip #{tmp}/dcm4chee-arr-3.0.11-mysql.zip").with(
      :cwd => prefix,
      :creates => "#{prefix}/dcm4chee-arr-3.0.11-mysql"
    )
  end

  # TODO: Change lib to linux 64 bit!
  it 'downloads jai-imageio when the basedir is missing' do
    File.should_receive(:exists?).with('/usr/local/jai_imageio-1_1').and_return(false)
    converge!
    expect(chef_run).to create_remote_file("#{tmp}/jai_imageio-1_1-lib-solaris-amd64.tar.gz").with(
      :source => 'http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-solaris-amd64.tar.gz',
      :checksum => '3d3ffb3d7b54d1d4f4abea824ec0bdf9d95223439b602d640e729832a1cb3008'
    )
  end

  # TODO: Change lib to linux 64 bit!
  it 'does not download jai-imageio when the basedir is present' do
    File.should_receive(:exists?).with('/usr/local/jai_imageio-1_1').and_return(true)
    converge!
    expect(chef_run).to_not create_remote_file("#{tmp}/jai_imageio-1_1-lib-solaris-amd64.tar.gz")
  end

  # TODO: Change lib to linux 64 bit!
  it 'does not unzip a tarball' do
    converge!
    expect(chef_run).to_not execute_command("unzip #{tmp}/jai_imageio-1_1-lib-solaris-amd64.tar.gz")
  end

  # TODO: Change lib to linux 64 bit!
  it 'unpacks jai-imageio' do
    converge!
    expect(chef_run).to execute_command("tar -xzf #{tmp}/jai_imageio-1_1-lib-solaris-amd64.tar.gz").with(
      :cwd => prefix,
      :creates => "#{prefix}/jai_imageio-1_1"
    )
  end
end
