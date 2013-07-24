#
# Cookbook Name:: dcm4chee
# Recipe:: default
#
# Copyright 2013, Björn Albers
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Initialize some helpers.
dcm4chee     = RemotePackage.new :dcm4chee, node
dcm4chee_arr = RemotePackage.new :dcm4chee_arr, node
jboss        = RemotePackage.new :jboss, node
jai_imageio  = RemotePackage.new :jai_imageio, node

# Required to unpack the remote packages.
package 'unzip' do
  action :install
end

# Download and unpack all packages.
[dcm4chee, jboss, dcm4chee_arr, jai_imageio].each do |pkg|
  remote_file pkg.destination do
    source pkg.source
    checksum pkg.checksum
    not_if { ::File.exists? pkg.basedir }
  end

  command = pkg.source =~ /\.zip$/ ? 'unzip' : 'tar -xzf'
  execute "#{command} #{pkg.destination}" do
    cwd pkg.prefix
    creates pkg.basedir
  end
end

# Install JBoss.
#jboss_install_log = File.join(dcm4chee.basedir, 'install_jboss.log')
# execute "./bin/install_jboss.sh #{jboss.basedir} > #{jboss_install_log}" do
#   cwd dcm4chee.basedir
#   creates jboss_install_log
# end
#
# # Install DCM4CHEE-ARR.
# dcm4chee_arr_install_log = File.join(dcm4chee.basedir, 'install_dcm4chee_arr.log')
# execute "./bin/install_arr.sh #{dcm4chee_arr.basedir} > #{dcm4chee_arr_install_log}" do
#   cwd dcm4chee.basedir
#   creates dcm4chee_arr_install_log
# end
