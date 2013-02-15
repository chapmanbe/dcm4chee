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

package "unzip" do
  action :install
end

# Download and extract the source archives for DCM4CHEE, JBoss, etc.
node[:dcm4chee][:source].each do |name, attributes|
  prefix         = node[:dcm4chee][:prefix] # Here we install everything.
  source_archive = Source.new(attributes)
  destination    = File.join(prefix, source_archive.filename)
  basedir        = File.join(prefix, source_archive.basename)

  remote_file destination do
    source source_archive.url
    checksum source_archive.checksum
  end

  command = source_archive.zip? ? "unzip" : "tar -xzf"
  execute "#{command} #{destination}" do
    cwd prefix
    creates basedir
  end
end
