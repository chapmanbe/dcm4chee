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

#include_recipe 'mysql::server'
#include_recipe 'database::mysql'
#include_recipe 'java'

dcm4chee_basedir = basedir(:dcm4chee)

# Required to unpack the remote packages.
package 'unzip' do
  action :install
end

[:dcm4chee, :jboss, :dcm4chee_arr, :jai_imageio].each do |pkg|
  destination = File.join Chef::Config[:file_cache_path], filename(pkg)
  remote_file destination do
    source   node[:dcm4chee][pkg][:source]
    checksum node[:dcm4chee][pkg][:checksum]
  end

  cmd = filename(pkg) =~ /\.zip$/ ? 'unzip' : 'tar -xzf'
  execute "unpack #{destination}" do
    command "#{cmd} #{destination}"
    cwd node[:dcm4chee][:prefix]
    #action :nothing
    subscribes :run, "remote_file[#{destination}]", :immediately
  end
end

# Run the install scripts for JBoss and DCM4CHEE-ARR.
# NOTE: The installers won't run when new versions for dcm4chee-arr and jboss are downloaded.
[:jboss, :dcm4chee_arr].each do |pkg|
  execute "./bin/#{node[:dcm4chee][pkg][:installer]} #{basedir(pkg)}" do
    cwd dcm4chee_basedir
  end
end

# Create symlink for convenience.
link File.join(node[:dcm4chee][:prefix], 'dcm4chee') do
  to dcm4chee_basedir
end

# Install Jai-Imageio.
%w[clib_jiio.dll clib_jiio_sse2.dll clib_jiio_util.dll].each do |dll|
  file File.join(dcm4chee_basedir, 'bin', 'native', dll) do
    action :delete
    backup false
  end
end
{
  'jai_imageio.jar'      => 'server/default/lib',
  'clibwrapper_jiio.jar' => 'server/default/lib',
  'libclib_jiio.so'      => 'bin/native'
}.each_pair do |file, target_dir|
  src = File.join(basedir(:jai_imageio), 'lib', file)
  dst = File.join(dcm4chee_basedir, target_dir, file)
  execute "cp #{src} #{dst}" do
    not_if { FileUtils.identical? src, dst }
  end
end

# Create system user and update ownership for installation.
user node[:dcm4chee][:user] do
  comment 'DCM4CHEE PACS'
  home dcm4chee_basedir
  system true
end
# TODO: Run this commmand only once!
ruby_block "change ownership for #{dcm4chee_basedir}" do
  block { FileUtils.chown_R node[:dcm4chee][:user], nil, dcm4chee_basedir }
end

## Create the PACS and ARR databases and grant permissions.
## TODO: Manage database configuration as template (see
## http://www.dcm4che.org/confluence/display/ee2/MySQL)!
#mysql_connection_params = {
#  :host     => 'localhost',
#  :username => 'root',
#  :password => node[:mysql][:server_root_password]
#}
#pacsdb_sql_file = File.join(dcm4chee_basedir,'sql', 'create.mysql')
#arrdb_sql_file  = File.join(basedir(:dcm4chee_arr),'sql',
#                            'dcm4chee-arr-mysql.ddl')
## See bug http://www.dcm4che.org/jira/browse/ARR-123
#ruby_block "fix #{arrdb_sql_file}" do
#  block do
#    rc = Chef::Util::FileEdit.new(arrdb_sql_file)
#    rc.search_file_replace(/type=/, 'engine=')
#    rc.write_file
#  end
#end
#{
#  'pacsdb' => pacsdb_sql_file,
#  'arrdb'  => arrdb_sql_file
#}.each_pair do |db, sql_file|
#  database = node[:dcm4chee][db]
#
#  mysql_database database[:name] do
#    connection mysql_connection_params
#    action :create
#    notifies :query, "mysql_database[initialize #{database[:name]}]",
#      :immediately
#  end
#
#  mysql_database "initialize #{database[:name]}" do
#    connection mysql_connection_params
#    database_name database[:name]
#    sql { ::File.open(sql_file).read }
#    action :nothing
#  end
#
#  mysql_database_user database[:user] do
#    connection mysql_connection_params
#    password database[:password]
#    database_name database[:name]
#    action :grant
#  end
#end

# Create init and config files to run dcm4chee.
template '/etc/init.d/dcm4chee' do
  source 'dcm4chee.erb'
  mode 0755
  owner 'root'
  group 'root'
end
template File.join(dcm4chee_basedir, 'bin', 'run.conf') do
  source 'run.conf.erb'
  owner node[:dcm4chee][:user]
  mode 0644
end
