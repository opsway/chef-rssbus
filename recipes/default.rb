#
# Cookbook Name:: rssbus
# Recipe:: default
#
# Copyright 2013, OPSWAY
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java"

template "/etc/init.d/jetty" do
  source "#{node['rssbus']['initd_script']}"
  mode "0755"
  owner "root"
  group "root"
  notifies :run, "execute[create-startup-scripts]", :immediately
end

execute "create-startup-scripts" do
  command "update-rc.d -f jetty defaults"
  not_if {  ::File.exists? "/etc/rc3.d/S20jetty" }
end

service "jetty" do
  supports :restart => true, :reload => true
  action [ :enable, :start ]
end

temp_file = "#{node['rssbus']['dir']}/rssbus_src.tar.gz"
remote_file "#{temp_file}" do
    source "https://www.rssbus.com/download/GetFile.aspx?file=free/AAY3-U/setup.tar.gz&name=AS2%20Connector%20(Cross-Platform%20Unix/Linux/Java%20Setup)&go=true"
    mode "0644"
    action :create
    notifies :run, "execute[untar]", :immediately
    notifies :run, "template[/etc/init.d/jetty]", :immediately
end

execute "untar" do
  command "cd #{node['rssbus']['dir']} && tar -xzvf #{temp_file} && rm -f #{temp_file}"
  not_if {  ::File.exists? "#{node['rssbus']['dir']}/RSSBusApps" }
  notifies :run, "execute[set-pass]", :immediately
  notifies :run, "template[#{node['rssbus']['dir']}/RSSBusApps/webserver/etc/jetty.xml]", :immediately
end

execute "set-pass" do
  command "cd #{node['rssbus']['dir']}/RSSBusApps && java -jar configure.jar -password #{node['rssbus']['admin_password']} " +
    "&& touch #{node['rssbus']['dir']}/RSSBusApps/password-is-set"
  not_if {  ::File.exists? "#{node['rssbus']['dir']}/RSSBusApps/password-is-set" }
end

template "#{node['rssbus']['dir']}/RSSBusApps/webserver/etc/jetty.xml" do
  source "jetty.xml.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
      :ports => node['rssbus']['listening_ports']
  )
  notifies :restart, resources(:service => "jetty"), :immediately
end

template "/etc/logrotate.d/jetty" do
  source "jetty.logrotate.erb"
  owner "root"
  group "root"
  mode 0644
end

