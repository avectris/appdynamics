# AppDynamics Cookbook

This is a fork from [appdynamics-cookbooks](https://github.com/Appdynamics/appdynamics-cookbooks) reduced to the Appdynamics machine and java agent with some fixes and configuration extends. It is fully productive used in a well known insurance company in Switzerland for Tomcat nodes.

Learn more about AppDynamics at:

* http://www.appdynamics.com/ (and check out the handsome devil next to the "Act" bubble in the photo)
* https://docs.appdynamics.com/display/PRO41/Getting+Started
* https://docs.appdynamics.com/display/PRO41/Install+and+Administer+Agents

## Requirements

* Chef >= 0.10.0
* unzip

## Attributes

### Default Attributes

These node attributes must be set to use the `_agent` recipes:

* `node['appdynamics']['app_name']` - The name to register your application under with the AppDynamics controller.
* `node['appdynamics']['tier_name']` - The name to register this tier of your application under with the AppDynamics controller.
* `node['appdynamics']['node_name']` - The name to register this node of your application under with the AppDynamics controller. Default is the `host name`
* `node['appdynamics']['unique_host_id_name']` - The name to register the unique host id name of your application under with the AppDynamics controller. Default is the `host name`
* `node['appdynamics']['version']` - The version of AppDynamics to use. Agent version overrides this. The package URI will be composed with the version
* `node['appdynamics']['controller']['host']` - The host your AppDynamics controller is running on (a domain name or IP address).
* `node['appdynamics']['controller']['port']` - The port your AppDynamics controller is running on.
* `node['appdynamics']['controller']['user']` - The account name to use with your AppDynamics controller.
* `node['appdynamics']['controller']['accesskey']` - The access key for your account for accessing your AppDynamics controller.

Optional attributes:

* `node['appdynamics']['packages_site']` - The base URL of the AppDynamics packages site (defaults to `https://packages.appdynamics.com`).
* `node['appdynamics']['controller']['ssl']` - Flag indicating if SSL should be used to speak to the controller (`true`) or not (`false`). Defaults to `true`. SaaS controllers do not support the value `false` for this flag.

### HTTP Proxy Attributes

If your agents must use an HTTP proxy to communicate with the controller, set these attributes:

* `node['appdynamics']['http_proxy']['host']` - The hostname/IP of your HTTP proxy.
* `node['appdynamics']['http_proxy']['port']` - The port of your HTTP proxy.
* `node['appdynamics']['http_proxy']['user']` - If you must authenticate with your HTTP proxy, the user name to authenticate as.
* `node['appdynamics']['http_proxy']['password_file']` - If you must authenticate with your HTTP proxy, the complete path to a file you will create on a machine using an AppDynamics agent that contains the password used for authenticating with your HTTP proxy.

#### Machine Agent Configuration Attributes

The `machine_agent` recipe has some additional attributes you may set:

* `node['appdynamics']['machine_agent']['version']` - The version of the AppDynamics package for the machine agent
* `node['appdynamics']['machine_agent']['source']` - Set complete URI of zip package to download from. Default `nil` because it is composed by package_site, version, (machineagent-bundle-, arch, OS) AgentName and .zip suffix.
* `node['appdynamics']['machine_agent']['use_bundled_package']` - Include machineagent-bundle-, arch and OS into source URI
* `node['appdynamics']['machine_agent']['checksum']` - The sha256 checksum of the source package
* `node['appdynamics']['machine_agent']['install_dir']` - Installation directory of the machine agent. Default `/opt/appdynamics/machineagent`
* `node['appdynamics']['machine_agent']['owner']` - User of the machine agent. Default `root`
* `node['appdynamics']['machine_agent']['group']` - Group of the machine agent. Default `root`
* `node['appdynamics']['machine_agent']['init_script']` - Path and name of the init script. Default `/etc/init.d/appdynamics_machine_agent`
* `node['appdynamics']['machine_agent']['pid_file']` - Path and name of the pid file. Default `/var/run/appdynamics_machine_agent.pid`
* `node['appdynamics']['machine_agent']['template']['cookbook']` - Name of the cookbook template folder for the controller-info-xml. Default `appdynamics`
* `node['appdynamics']['machine_agent']['template']['source']` - Location of the template file for the controller-info.xml . Default `machine/controller-info.xml.erb`
* `node['appdynamics']['machine_agent']['init']['cookbook']` - Name of the cookbook template folder for the init script. Default `appdynamics`
* `node['appdynamics']['machine_agent']['init']['source']` - Location of the template file for the init script. Default `machine/init.d.erb`
* `node['appdynamics']['machine_agent']['run_sh']['cookbook']` - Name of the cookbook template folder for the run.sh script. Default `appdynamics`
* `node['appdynamics']['machine_agent']['run_sh']['source']` - Location of the template file for the run.sh script. Default `machine/run.sh.erb`
* `node['appdynamics']['machine_agent']['java']` - Path of the java binary. Default `/usr/bin/java`
* `node['appdynamics']['machine_agent']['java_params']` - System properties to pass to the JVM of the machine agent (space separated). Default `Xmx32m`

#### Java Agent Configuration Attributes

* `node['appdynamics']['java_agent']['version']` - The version of the AppDynamics package for the java agent
* `node['appdynamics']['java_agent']['source']` - Set complete URI of zip package to download from. Default `nil` becaus
e it is composed by package_site, /java/, version, AppServerAgent-, (ibm-), version and .zip suffix.
* `node['appdynamics']['java_agent']['ibm_jvm']` - Include "ibm-" between AppServerAgent- and version.zip in the composed package URI. Default `false`
* `node['appdynamics']['java_agent']['checksum']` - The sha256 checksum of the source package
* `node['appdynamics']['java_agent']['install_dir']` - Installation directory of the java agent. The package contains the root folder "javaagent". Default `/opt/appdynamics`
* `node['appdynamics']['java_agent']['owner']` - User of the java agent. To avoid permission problem, set the same user as your JVM is running (tomcat, jboss, etc) . Default `root`
* `node['appdynamics']['java_agent']['group']` - Group of the java agent. Default `root`

* `node['appdynamics']['java_agent']['template']['cookbook']` - Name of the cookbook template folder for the controller-info-xml. This is normally not needed as you pass java agent settings through system properties of your JVM. Default `appdynamics`
* `node['appdynamics']['java_agent']['template']['source']` - Location of the template file for the controller-info.xml. his is normally not needed as you pass java agent settings through system properties of your JVM. Default `machine/controller-info.xml.erb`
* `node['appdynamics']['java_agent']['zip']` - The file name of the package to be saved on the file system. Default `#{Chef::Config[:file_cache_path]}/AppDynamicsJavaAgent.zip`

## Example usage

**Step 1.** Define attributes.

```ruby
default_attributes (
  'appdynamics' => {
    'machine_agent' => {
      'version: => '4.5.7.1975'
    },
    'java_agent' => {
      'version' => '4.5.6.24621',
      'owner' => 'tomcat',
      'group' => 'tomcat'
    },
    'app_name' => 'my app',
    'tier_name' => 'frontend',
    'node_name' => node.name,
    'unique_host_id_name' => node.name,
    'controller' => {
      'host' => 'my-controller',
      'port' => '8081',
      'ssl' => false,
      'user' => 'someuser',
      'accesskey' => 'supersecret',
    }
  }
)
```

**Step 2.** Add `recipe[appdynamics::machine_agent]` and/or `recipe[appdynamics:java_agent]` to your run list.

## Built With

* [chef](https://www.chef.io) - Chef Software, Inc

## Contributing

Please read [CONTRIBUTING](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Roland Hansmann** - *Initial work* - [Roland Hansmann](https://github.com/rediculum)

See also the list of [contributors](https://github.com/avectris/appdynamics/graphs/contributors) who participated in this project.

## License

This project is licensed under the GNU Affero General Public License v3.0 License - see the [LICENSE](LICENSE) file for details
