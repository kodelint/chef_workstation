#
# Cookbook Name:: chef_workstation
# Recipe:: default
#
# Copyright (c) 2016 Satyajit Roy, All Rights Reserved.
package_url = node['chef_workstation']['chefdk']['url']
package_name = ::File.basename(package_url)
package_local_path = "#{Chef::Config[:file_cache_path]}/#{package_name}"

# package is remote, let's download it
remote_file package_local_path do
  source package_url
end

package package_name do
  source package_local_path
  provider Chef::Provider::Package::Dpkg
  action :install
end

admin_home = "#{node['chef_workstation']['admin']['user']['home']}"
admin_user = "#{node['chef_workstation']['admin']['username']}"
org_name = "#{node['chef_workstation']['orgname']['shortname']}"
chefserver = "#{node['chef_workstation']['server']}"
org_name = "#{node['chef_workstation']['orgname']['shortname']}"

directory "#{admin_home}/.chef" do
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  action :create
end

directory "#{admin_home}/repos" do
  owner 'vagrant'
  group 'vagrant'
  mode '0755'
  action :create
end

template 'Generate knife config' do
  path "#{admin_home}/.chef/knife.rb"
  source 'knife.rb.erb'
  owner 'vagrant'
  group 'vagrant'
  variables(
    :admin_node_name => "#{admin_user}",
    :org_client_validation_key => "#{org_name}",
    :org_user_home => "#{admin_home}",
    :node_fqdn => "#{chefserver}",
    :org_name => "#{org_name}"
  )
end

