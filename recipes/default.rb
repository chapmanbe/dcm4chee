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


package 'unzip' do
  action :install
end

# Download and unpack all archives.
%w[dcm4chee jboss dcm4chee_arr jai_imageio].each do |name|
  archive     = node[:dcm4chee][:source][name]
  url         = archive[:source]
  destination = File.join Chef::Config[:file_cache_path], filename(url)
  basedir     = File.join node[:dcm4chee][:prefix],
    (archive[:basename] || basename(url))

  remote_file destination do
    source url
    checksum archive[:checksum]
    not_if { ::File.exists? basedir }
  end

  command = filename(url) =~ /\.zip$/ ? 'unzip' : 'tar -xzf'
  execute "#{command} #{destination}" do
    cwd node[:dcm4chee][:prefix]
    creates basedir
  end
end
