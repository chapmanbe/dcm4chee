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
  destination = File.join Chef::Config[:file_cache_path], pkg.filename
  remote_file destination do
    source pkg.source
    checksum pkg.checksum
    not_if { ::File.exists? pkg.basedir }
  end

  command = pkg.source =~ /\.zip$/ ? 'unzip' : 'tar -xzf'
  execute "#{command} #{destination}" do
    cwd pkg.prefix
    creates pkg.basedir
  end
end

# Run the install scripts for JBoss and DCM4CHEE-ARR.
jboss_install_log = File.join(dcm4chee.basedir, 'install_jboss.log')
execute "./bin/install_jboss.sh #{jboss.basedir} > #{jboss_install_log}" do
  cwd dcm4chee.basedir
  creates jboss_install_log
end
dcm4chee_arr_install_log = File.join(dcm4chee.basedir, 'install_arr.log')
execute "./bin/install_arr.sh #{dcm4chee_arr.basedir} > #{dcm4chee_arr_install_log}" do
  cwd dcm4chee.basedir
  creates dcm4chee_arr_install_log
end

# Install Jai-Imageio.
%w[clib_jiio.dll clib_jiio_sse2.dll clib_jiio_util.dll].each do |dll|
  file File.join(dcm4chee.basedir, 'bin', 'native', dll) do
    action :delete
    backup false
  end
end
{
  'jai_imageio.jar'      => 'server/default/lib',
  'clibwrapper_jiio.jar' => 'server/default/lib',
  'libclib_jiio.so'      => 'bin/native'
}.each_pair do |file, target_dir|
  src = File.join(jai_imageio.basedir, 'lib', file)
  dst = File.join(dcm4chee.basedir, target_dir, file)
  execute "cp #{src} #{dst}" do
    not_if { FileUtils.identical? src, dst }
  end
end
