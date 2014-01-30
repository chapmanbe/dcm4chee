default[:dcm4chee][:prefix] = '/usr/local'
default[:dcm4chee][:user]   = 'dcm4chee'

default[:dcm4chee][:jboss] = {
  :source   => "http://downloads.sourceforge.net/project/jboss/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA.zip",
  :checksum => "a5d518286dae6ea432a6f7a5506c2338ad1751ae4b6d7ce2082436b2d3f87f46",
  :installer => "install_jboss.sh"
}
default[:dcm4chee][:dcm4chee_arr] = {
  :source   => "http://downloads.sourceforge.net/project/dcm4che/dcm4chee-arr/3.0.11/dcm4chee-arr-3.0.11-mysql.zip",
  :checksum => "3de87af391d127b04da8000a1398622283cbb0dc4ffa4a769d8d45a106b43f94",
  :installer => 'install_arr.sh'
}
default[:dcm4chee][:dcm4chee] = {
  :source   => "http://downloads.sourceforge.net/project/dcm4che/dcm4chee/2.17.1/dcm4chee-2.17.1-mysql.zip",
  :checksum => "7597cf96620c58edf4a00499adbcd8f26a78c3c5127ebfa8567810bb0dc737b6"
}
default[:dcm4chee][:jai_imageio] = {
  :source   => "http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz",
  :checksum => "78f24c75b70a93b82de05c9a024574973f2ee71c25bf068d470e5abd511fb49a",
  :basename => "jai_imageio-1_1" # Overwrite the basename because it differs from the source archive filename.
}
# NOTE: Dcm4chee always uses the default parameters, even if us overwrite these
# attributes!
default[:dcm4chee][:pacsdb] = {
  :name     => 'pacsdb',
  :user     => 'pacs',
  :password => 'pacs'
}
default[:dcm4chee][:arrdb] = {
  :name     => 'arrdb',
  :user     => 'arr',
  :password => 'arr'
}

# MySQL should only listen on localhost (was on eth0 before!).
set[:mysql][:bind_address] = '127.0.0.1'

# Install Oracle Java
set[:java] = {
  :install_flavor => 'oracle',
  :oracle => {
    :accept_oracle_download_terms => true
  }
}
