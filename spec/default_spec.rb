require 'spec_helper'

describe 'dcm4chee::default' do
  let(:chef_run)             { ChefSpec::ChefRunner.new({:evaluate_guards => true}) }
  let(:tmp)                  { Chef::Config[:file_cache_path] }
  let(:prefix)               { '/usr/local' }
  let(:dcm4chee_basedir)     { "#{prefix}/dcm4chee-2.17.1-mysql" }
  let(:jboss_basedir)        { "#{prefix}/jboss-4.2.3.GA" }
  let(:jai_imageio_basedir)  { "#{prefix}/jai_imageio-1_1" }
  let(:dcm4chee_arr_basedir) { "#{prefix}/dcm4chee-arr-3.0.11-mysql" }

  let(:packages) do
    {
      dcm4chee: {
        url:      'http://downloads.sourceforge.net/project/dcm4che/dcm4chee/2.17.1/dcm4chee-2.17.1-mysql.zip',
        filename: 'dcm4chee-2.17.1-mysql.zip',
        basedir:  'dcm4chee-2.17.1-mysql',
        checksum: '7597cf96620c58edf4a00499adbcd8f26a78c3c5127ebfa8567810bb0dc737b6'
      },
      jboss: {
        url:      'http://downloads.sourceforge.net/project/jboss/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA.zip',
        filename: 'jboss-4.2.3.GA.zip',
        basedir:  'jboss-4.2.3.GA',
        checksum: 'a5d518286dae6ea432a6f7a5506c2338ad1751ae4b6d7ce2082436b2d3f87f46'
      },
      dcm4chee_arr: {
        url:      'http://downloads.sourceforge.net/project/dcm4che/dcm4chee-arr/3.0.11/dcm4chee-arr-3.0.11-mysql.zip',
        filename: 'dcm4chee-arr-3.0.11-mysql.zip',
        basedir:  'dcm4chee-arr-3.0.11-mysql',
        checksum: '3de87af391d127b04da8000a1398622283cbb0dc4ffa4a769d8d45a106b43f94'
      },
      jai_imageio: {
        url:      'http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz',
        filename: 'jai_imageio-1_1-lib-linux-amd64.tar.gz',
        basedir:  'jai_imageio-1_1',
        checksum: '78f24c75b70a93b82de05c9a024574973f2ee71c25bf068d470e5abd511fb49a'
      }
    }
  end

  before(:each) do
    ::File.stub(:exists?).and_call_original
    ::FileUtils.stub(:identical?).and_call_original

    #secure_password = 'foo'
    #chef_run.node.set[:mysql][:server_debian_password] = secure_password
    #chef_run.node.set[:mysql][:server_root_password]   = secure_password
    #chef_run.node.set[:mysql][:server_repl_password]   = secure_password
  end

  def converge!
    chef_run.converge 'dcm4chee::default'
  end

  it 'installs unzip' do
    converge!
    expect(chef_run).to install_package('unzip')
  end

  [ :dcm4chee, :jboss, :dcm4chee_arr, :jai_imageio ].each do |name|
    it "downloads #{name}" do
      pkg = packages[name]
      File.should_receive(:exists?).with("#{prefix}/#{pkg[:basedir]}").and_return(false) # TODO: Remove this!
      converge!
      expect(chef_run).to create_remote_file("#{tmp}/#{pkg[:filename]}").with(
        source: pkg[:url],
        checksum: pkg[:checksum]
      )
    end
  end

  [ :dcm4chee, :jboss, :dcm4chee_arr ].each do |name|
    it "unpacks #{name}" do
      converge!
      pkg = packages[name]
      expect(chef_run).to execute_command("unzip #{tmp}/#{pkg[:filename]}").with(
        cwd: prefix,
        creates: "#{prefix}/#{pkg[:basedir]}"
      )
    end
  end

  [ :jai_imageio].each do |name|
    it "unpacks #{name}" do
      converge!
      pkg = packages[name]
      expect(chef_run).to execute_command("tar -xzf #{tmp}/#{pkg[:filename]}").with(
        cwd: prefix,
        creates: "#{prefix}/#{pkg[:basedir]}"
      )
    end
  end

  it 'installs jboss' do
    converge!
    expect(chef_run).to execute_command("./bin/install_jboss.sh #{jboss_basedir} > #{dcm4chee_basedir}/install_jboss.log").with(
      :cwd => dcm4chee_basedir,
      :creates => "#{dcm4chee_basedir}/install_jboss.log"
    )
  end

  it 'installs dcm4chee-arr' do
    converge!
    expect(chef_run).to execute_command("./bin/install_arr.sh #{dcm4chee_arr_basedir} > #{dcm4chee_basedir}/install_arr.log").with(
      :cwd => dcm4chee_basedir,
      :creates => "#{dcm4chee_basedir}/install_arr.log"
    )
  end

  [
    'clib_jiio.dll',
    'clib_jiio_sse2.dll',
    'clib_jiio_util.dll'
  ].each do |dll|
    it "removes #{dll}" do
      converge!
      expect(chef_run).to delete_file "#{dcm4chee_basedir}/bin/native/#{dll}"
    end
  end

  {
    'jai_imageio.jar'      => 'server/default/lib',
    'clibwrapper_jiio.jar' => 'server/default/lib',
    'libclib_jiio.so'      => 'bin/native'
  }.each_pair do |file, target_dir|
    it "copies #{file} unless already done" do
      src = "#{jai_imageio_basedir}/lib/#{file}"
      dst = "#{dcm4chee_basedir}/#{target_dir}/#{file}"
      cmd = "cp #{src} #{dst}"
      FileUtils.should_receive(:identical?).with(src, dst).
        and_return(false, true)
      converge!
      expect(chef_run).to execute_command cmd
      converge!
      expect(chef_run).to_not execute_command cmd
    end
  end

  {
    'weasis.war' => {
      :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/1.2.5/weasis.war',
      :checksum => '7947193bfee1fdf03050e3b0c62654e5867ae565fdb7730de67780ef2d25df84'
    },
    'weasis-i18n.war' => {
      :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/1.2.5/weasis-i18n.war',
      :checksum => '59a18c777208af1dc7012214f4d969f4d1d0279116f477b33923cdfebd32b41c'
    },
    'weasis-pacs-connector.war' => {
      :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/dcm4chee-web3/3.0.3-r1/weasis-pacs-connector.war',
      :checksum => '7fd28e78ddaf9e1cce91354848895839ce4de014890513262dab49e707705e5a'
    },
    'dcm4chee-web-weasis.jar' => {
      :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/dcm4chee-web3/3.0.3-r1/dcm4chee-web-weasis.jar',
      :checksum => '05a89e7d0a90d2da81c27b6d945db7ded59636ea6d45043556628bde7462b5fe'
    }
  }.each_pair do |file,attributes|
    it "downloads #{file} to the deploy dir" do
      dst = "#{dcm4chee_basedir}/server/default/deploy/#{file}"
      converge!
      expect(chef_run).to create_remote_file(dst).with(attributes)
    end
  end
end
