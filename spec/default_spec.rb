require "spec_helper"

describe "chef-dcm4chee::default" do
  let(:prefix) { "/usr/local" }
  let(:chef_run) { ChefSpec::ChefRunner.new.converge "chef-dcm4chee::default" }

  it "installs unzip to extract the sources" do
    expect(chef_run).to install_package("unzip")
  end

  it "downloads the sources for jboss" do
    expect(chef_run).to create_remote_file("#{prefix}/jboss-4.2.3.GA.zip").with(
      :source => "http://downloads.sourceforge.net/project/jboss/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA.zip",
      :checksum => "a5d518286dae6ea432a6f7a5506c2338ad1751ae4b6d7ce2082436b2d3f87f46"
    )
  end

  it "downloads the sources for dcm4chee" do
    expect(chef_run).to create_remote_file("#{prefix}/dcm4chee-2.17.1-mysql.zip").with(
      :source => "http://downloads.sourceforge.net/project/dcm4che/dcm4chee/2.17.1/dcm4chee-2.17.1-mysql.zip",
      :checksum => "7597cf96620c58edf4a00499adbcd8f26a78c3c5127ebfa8567810bb0dc737b6"
    )
  end

  it "downloads the sources for dcm4chee-arr" do
    expect(chef_run).to create_remote_file("#{prefix}/dcm4chee-arr-3.0.11-mysql.zip").with(
      :source => "http://downloads.sourceforge.net/project/dcm4che/dcm4chee-arr/3.0.11/dcm4chee-arr-3.0.11-mysql.zip",
      :checksum => "3de87af391d127b04da8000a1398622283cbb0dc4ffa4a769d8d45a106b43f94"
    )
  end

  it "downloads the sources for jai-imageio" do
    expect(chef_run).to create_remote_file("#{prefix}/jai_imageio-1_1-lib-solaris-amd64.tar.gz").with(
      :source => "http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-solaris-amd64.tar.gz",
      :checksum => "3d3ffb3d7b54d1d4f4abea824ec0bdf9d95223439b602d640e729832a1cb3008"
    )
  end

  it "unzips the jboss sources" do
    expect(chef_run).to execute_command("unzip #{prefix}/jboss-4.2.3.GA.zip").with(
      :cwd => "/usr/local",
      :creates => "/usr/local/jboss-4.2.3.GA"
    )
  end

  it "unzips the dcm4chee-arr sources" do
    expect(chef_run).to execute_command("unzip #{prefix}/dcm4chee-arr-3.0.11-mysql.zip").with(
      :cwd => "/usr/local",
      :creates => "/usr/local/dcm4chee-arr-3.0.11-mysql"
    )
  end

  it "unzips the dcm4chee sources" do
    expect(chef_run).to execute_command("unzip #{prefix}/dcm4chee-2.17.1-mysql.zip").with(
      :cwd => "/usr/local",
      :creates => "/usr/local/dcm4chee-2.17.1-mysql"
    )
  end

  it "does not unzip a tarball" do
    expect(chef_run).to_not execute_command("unzip #{prefix}/jai_imageio-1_1-lib-solaris-amd64.tar.gz")
  end

  it "untars the jai-imageio sources" do
    expect(chef_run).to execute_command("tar -xzf #{prefix}/jai_imageio-1_1-lib-solaris-amd64.tar.gz").with(
      :cwd => "/usr/local",
      :creates => "/usr/local/jai_imageio-1_1"
    )
  end
end
