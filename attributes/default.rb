default[:dcm4chee][:prefix] = '/usr/local'
default[:dcm4chee][:user]   = 'dcm4chee'

default[:dcm4chee][:source] = {
  :jboss => {
    :source   => "http://downloads.sourceforge.net/project/jboss/JBoss/JBoss-4.2.3.GA/jboss-4.2.3.GA.zip",
    :checksum => "a5d518286dae6ea432a6f7a5506c2338ad1751ae4b6d7ce2082436b2d3f87f46"
  },
  :dcm4chee_arr => {
    :source   => "http://downloads.sourceforge.net/project/dcm4che/dcm4chee-arr/3.0.11/dcm4chee-arr-3.0.11-mysql.zip",
    :checksum => "3de87af391d127b04da8000a1398622283cbb0dc4ffa4a769d8d45a106b43f94"
  },
  :dcm4chee => {
    :source   => "http://downloads.sourceforge.net/project/dcm4che/dcm4chee/2.17.1/dcm4chee-2.17.1-mysql.zip",
    :checksum => "7597cf96620c58edf4a00499adbcd8f26a78c3c5127ebfa8567810bb0dc737b6"
  },
  :jai_imageio => {
    :source   => "http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz",
    :checksum => "78f24c75b70a93b82de05c9a024574973f2ee71c25bf068d470e5abd511fb49a",
    :basename => "jai_imageio-1_1" # Overwrite the basename because it differs from the source archive filename.
  },
  :weasis => {
    :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/1.2.5/weasis.war',
    :checksum => '7947193bfee1fdf03050e3b0c62654e5867ae565fdb7730de67780ef2d25df84'
  },
  :weasis_i18n => {
    :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/1.2.5/weasis-i18n.war',
    :checksum => '59a18c777208af1dc7012214f4d969f4d1d0279116f477b33923cdfebd32b41c'
  },
  :weasis_pacs_connector => {
    :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/dcm4chee-web3/3.0.3-r1/weasis-pacs-connector.war',
    :checksum => '7fd28e78ddaf9e1cce91354848895839ce4de014890513262dab49e707705e5a'
  },
  :dcm4chee_web_weasis => {
    :source   => 'http://downloads.sourceforge.net/project/dcm4che/Weasis/dcm4chee-web3/3.0.3-r1/dcm4chee-web-weasis.jar',
    :checksum => '05a89e7d0a90d2da81c27b6d945db7ded59636ea6d45043556628bde7462b5fe'
  }
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
