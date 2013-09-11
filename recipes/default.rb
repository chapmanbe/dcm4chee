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

include_recipe 'mysql::server'
include_recipe 'database::mysql'
include_recipe 'java'

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

# Create symlink for convenience.
link File.join(dcm4chee.prefix, 'dcm4chee') do
  to dcm4chee.basedir
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

# Install Weasis.
# TODO: Update jmx settings for dcm4chee!
#   (see http://www.dcm4che.org/confluence/display/WEA/Installing+Weasis+in+DCM4CHEE)
# TODO: copy the config files as templates!
# TODO: Restart dcm4chee afterwarts if any file was downloaded, new created or changed!
[
  :weasis,
  :weasis_i18n,
  :weasis_pacs_connector,
  :dcm4chee_web_weasis
].each do |name|
  pkg = RemotePackage.new name, node
  dst = File.join dcm4chee.basedir, 'server', 'default', 'deploy',
    pkg.filename
  remote_file dst do
    source pkg.source
    checksum pkg.checksum
  end
end

# Create system user and update ownership for installation.
user node[:dcm4chee][:user] do
  comment 'DCM4CHEE PACS'
  home dcm4chee.basedir
  system true
end
# TODO: Run this commmand only once!
ruby_block "change ownership for #{dcm4chee.basedir}" do
  block { FileUtils.chown_R node[:dcm4chee][:user], nil, dcm4chee.basedir }
end

# Create the PACS and ARR databases and grant permissions.
# TODO: Manage database configuration as template (see
# http://www.dcm4che.org/confluence/display/ee2/MySQL)!
mysql_connection_params = {
  :host     => 'localhost',
  :username => 'root',
  :password => node[:mysql][:server_root_password]
}
pacsdb_sql_file = File.join(dcm4chee.basedir,'sql', 'create.mysql')
arrdb_sql_file  = File.join(dcm4chee_arr.basedir,'sql',
                            'dcm4chee-arr-mysql.ddl')
# See bug http://www.dcm4che.org/jira/browse/ARR-123
ruby_block "fix #{arrdb_sql_file}" do
  block do
    rc = Chef::Util::FileEdit.new(arrdb_sql_file)
    rc.search_file_replace(/type=/, 'engine=')
    rc.write_file
  end
end
{
  'pacsdb' => pacsdb_sql_file,
  'arrdb'  => arrdb_sql_file
}.each_pair do |db, sql_file|
  database = node[:dcm4chee][db]

  mysql_database database[:name] do
    connection mysql_connection_params
    action :create
    notifies :query, "mysql_database[initialize #{database[:name]}]",
      :immediately
  end

  mysql_database "initialize #{database[:name]}" do
    connection mysql_connection_params
    database_name database[:name]
    sql { ::File.open(sql_file).read }
    action :nothing
  end

  mysql_database_user database[:user] do
    connection mysql_connection_params
    password database[:password]
    database_name database[:name]
    action :grant
  end
end
