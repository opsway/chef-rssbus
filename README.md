rssbus Cookbook
===============
Install RSSBus AppServer with Jetty.
Takes source tarball with EC2 Connector from RSSBus site.

Requirements
------------
Requires java cookbook

#### packages
- `java` - rssbus needs toaster to brown your bagel.

Attributes
----------
default['rssbus']['dir'] = '/usr/lib'
default['rssbus']['src_tarball'] = 'AS2ConnectorCrossPlatformUnixLinuxJavaSetup.tar.gz'
default['rssbus']['initd_script'] = 'run.sh.erb'
default['rssbus']['listening_ports'] = []
default['rssbus']['service'] = 'jetty'
default['rssbus']['pid_file'] = '/var/run/jetty.pid'
default['rssbus']['admin_password'] = 'test'

Usage
-----
#### rssbus::default
Just include `rssbus` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[rssbus]"
  ]
}
```
