#
# Cookbook Name:: mongrel2
# Recipe:: default
#
# Author:: Thomas Rampelberg (<thomas@saunter.org>)
#
# Copyright 2011, Thomas Rampelberg
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

include_recipe "build-essential"

def template(str, args)
    str.gsub(/%\{(.*?)\}/) { args[$1.to_sym] }
end

zeromq_tar_gz = File.join(Chef::Config[:file_cache_path], "/", "zeromq-#{node[:zeromq][:src_version]}.tar.gz")

src_mirror_url = template(
  node[:zeromq][:src_mirror], {:src_version => node[:zeromq][:src_version] }
)
install_dir = template(
  node[:zeromq][:install_dir], {:src_version => node[:zeromq][:src_version]}
)

remote_file zeromq_tar_gz do
  source src_mirror_url
end

package "uuid-dev" do
  action :upgrade
end

bash "install zeromq #{node[:zeromq][:src_version]}" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar -zxf #{zeromq_tar_gz}
    cd zeromq-#{node[:zeromq][:src_version]} && ./configure --prefix=#{install_dir} && make && make install
    echo -e "/opt/zeromq-#{node[:zeromq][:src_version]}/lib\\n" > /etc/ld.so.conf.d/#{node[:zeromq][:src_version]}.conf
    ldconfig
  EOH
  not_if { ::FileTest.exists?("#{install_dir}/lib/libzmq.so") }
end
