#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2011, Opscode, Inc.
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
rs_utils_marker :begin

if node["redis2"]["install_from"] == "package"
  include_recipe "redis2::package"
else
  include_recipe "redis2::source"
end

user node["redis2"]["user"] do
  home node["redis2"]["data_dir"]
  system true
end

directory node["redis2"]["instances"]["default"]["data_dir"] do
  owner node["redis2"]["user"]
  mode "0750"
  recursive true
end

log "#{node["redis2"]["conf_dir"]}"
directory node["redis2"]["conf_dir"]

directory node["redis2"]["pid_dir"] do
  owner node["redis2"]["user"]
  mode "0750"
  recursive true
end

directory node["redis2"]["log_dir"] do
  owner node["redis2"]["user"]
  mode "0750"
end

service "redis" do
  service_name value_for_platform(:default => "redis", [:ubuntu, :debian] => {:default => "redis-server"})
  action [:disable, :stop]
  ignore_failure true
end

bash "delete redis conf" do
  user "root"
  cwd "/"
  code <<-EOF
  rm -fr  "#{node["redis2"]["conf_dir"]}/redis.conf"
  EOF
  only_if "test -e #{node["redis2"]["conf_dir"]}/redis.conf"
end

remote_file "/tmp/redis-2.1.1.gem" do
  source "http://rubygems.org/downloads/redis-2.1.1.gem"
  owner "root" 
  group "root"
  mode "0644"
end

gem_package "redis" do
  action :install
  gem_binary "/usr/bin/gem"
  version "2.1.1"
end

Gem.clear_paths

rs_utils_marker :end
