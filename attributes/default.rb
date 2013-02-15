default[:dcm4chee][:prefix] = "/usr/local"

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
    :source   => "http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-solaris-amd64.tar.gz",
    :checksum => "3d3ffb3d7b54d1d4f4abea824ec0bdf9d95223439b602d640e729832a1cb3008",
    :basename => "jai_imageio-1_1" # Overwrite the basename because it differs from the source archive filename.
  }
}
