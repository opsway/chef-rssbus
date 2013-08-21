#
# Cookbook Name:: rssbus
# Recipe:: default
#
# Copyright 2013, OPSWAY
#
# All rights reserved - Do Not Redistribute
#

include_recipe "java"


temp_file = "#{node['rssbus']['dir']}/rssbus_src.tar.bz"
remote_file "#{temp_file}" do
    source "#{node['rssbus']['source_file_address']}"
    mode "0644"
    action :create
    Array(node['rssbus']['listening_ports']).each do | port |
      notifies :run, "execute[untar#{port}]", :immediately
    end
    notifies :create, "template[/etc/init.d/jetty]", :immediately
end


Array(node['rssbus']['listening_ports']).each do | port |
  execute "untar#{port}" do
    command "cd #{node['rssbus']['dir']} && tar -xjvf #{temp_file} && mv RSSBusApps RSSBusApps#{port}"
    action :run
    not_if {  ::File.exists? "#{node['rssbus']['dir']}/RSSBusApps#{port}" }
    notifies :run, "execute[set-pass#{port}]", :delayed
    notifies :create, "template[#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty.xml]", :immediately
    notifies :create, "template[#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-contexts.xml]", :immediately
    notifies :create, "template[#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-deploy.xml]", :immediately
    notifies :create, "template[#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-logging.xml]", :immediately
    notifies :create, "template[#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-realm.xml]", :immediately
    notifies :create, "template[#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-requestlog.xml]", :immediately
    notifies :create, "template[#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-webapps.xml]", :immediately
  end

template "/etc/init.d/jetty" do
  source "#{node['rssbus']['initd_script']}"
  mode "0755"
  owner "root"
  group "root"
  action :create
  notifies :run, "execute[create-startup-scripts]", :immediately
  notifies :restart, "service[jetty]", :delayed
end

execute "create-startup-scripts" do
  command "update-rc.d -f jetty defaults"
  action :run
  not_if {  ::File.exists? "/etc/rc3.d/S20jetty" }
  notifies :restart, "service[jetty]", :delayed
end


template "/etc/logrotate.d/jetty" do
  source "jetty.logrotate.erb"
  owner "root"
  group "root"
  mode 0644
  action :create
end


  execute "set-pass#{port}" do
    command "cd #{node['rssbus']['dir']}/RSSBusApps#{port} && java -jar configure.jar -password #{node['rssbus']['admin_password']} " +
      "&& touch #{node['rssbus']['dir']}/RSSBusApps#{port}/password-is-set"
    not_if {  ::File.exists? "#{node['rssbus']['dir']}/RSSBusApps#{port}/password-is-set" }
    action :run
  end

  template "#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty.xml" do
    source "jetty.xml.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
        :port => port
    )
    notifies :restart, "service[jetty]", :delayed
  end

  template "#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-contexts.xml" do
    source "jetty-contexts.xml.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
        :port => port
    )
    notifies :restart, "service[jetty]", :delayed
  end

  template "#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-deploy.xml" do
    source "jetty-deploy.xml.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
        :port => port
    )
    notifies :restart, "service[jetty]", :delayed
  end

  template "#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-logging.xml" do
    source "jetty-logging.xml.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
        :port => port
    )
    notifies :restart, "service[jetty]", :delayed
  end

  template "#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-realm.xml" do
    source "jetty-realm.xml.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
        :port => port
    )
    notifies :restart, "service[jetty]", :delayed
  end

  template "#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-requestlog.xml" do
    source "jetty-requestlog.xml.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
        :port => port
    )
    notifies :restart, "service[jetty]", :delayed
  end

  template "#{node['rssbus']['dir']}/RSSBusApps#{port}/webserver/etc/jetty-webapps.xml" do
    source "jetty-webapps.xml.erb"
    owner "root"
    group "root"
    mode 0644
    variables(
        :port => port
    )
    notifies :restart, "service[jetty]", :delayed
  end
end # each

service "jetty" do
  supports :restart => true, :reload => true
  action [ :enable, :start ]
end

