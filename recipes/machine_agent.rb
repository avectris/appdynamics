agent = node['appdynamics']['machine_agent']
controller = node['appdynamics']['controller']
http_proxy = node['appdynamics']['http_proxy']

version = agent['version'] || node['appdynamics']['version']
raise 'You must specify either node[\'appdynamics\'][\'version\'] or node[\'appdynamics\'][\'machine_agent\'][\'version\']' unless version

agent_zip = "#{Chef::Config[:file_cache_path]}/AppDynamicsMachineAgent.zip"
package_source = agent['source']

unless package_source
  package_source = "#{node['appdynamics']['packages_site']}/machine/#{version}/"

  if agent['use_bundled_package']
    package_source << 'machineagent-bundle-'
    package_source << if node['kernel']['machine'] == 'x86_64'
                        '64bit-'
                      else
                        '32bit-'
                      end

    package_source << value_for_platform_family(
      %w(mswin windows) => 'windows',
      %w(darwin mac_os_x) => 'osx',
      %w(omnios opensolaris solaris solaris2 smartos) => 'solaris',
      'default' => 'linux'
    )
  else
    package_source << 'MachineAgent'
  end

  package_source << "-#{version}.zip"
end

package 'unzip'

directory "#{agent['install_dir']}/conf" do
  owner agent['owner']
  group agent['group']
  mode '0755'
  recursive true
  action :create
end

remote_file agent_zip do
  source package_source
  checksum agent['checksum']
  backup false
  mode '0444'
  notifies :run, 'execute[unzip-appdynamics-machine-agent]', :immediately
end unless ::File.exist?([agent['install_dir'], '/bin'].join)

template "#{agent['install_dir']}/run.sh" do
  cookbook agent['run_sh']['cookbook']
  source agent['run_sh']['source']
  owner agent['owner']
  group agent['group']
  mode '0744'
  variables(
    java: agent['java'],
    java_params: agent['java_params'],
    install_dir: agent['install_dir'],
    pid_file: agent['pid_file']
  )
end

execute 'unzip-appdynamics-machine-agent' do
  cwd agent['install_dir']
  command "unzip -qqo #{agent_zip}"
  action :nothing
end

template agent['init_script'] do
  cookbook agent['init']['cookbook']
  source agent['init']['source']
  variables(
    install_dir: agent['install_dir'],
    pid_file: agent['pid_file']
  )
  owner agent['owner']
  group agent['group']
  mode '0744'
end

template "#{agent['install_dir']}/conf/controller-info.xml" do
  cookbook agent['template']['cookbook']
  source agent['template']['source']
  owner agent['owner']
  group agent['group']
  sensitive true
  mode '0600'

  variables(
    app_name: node['appdynamics']['app_name'],
    tier_name: node['appdynamics']['tier_name'],
    node_name: node['appdynamics']['node_name'],
    unique_host_id_name: node['appdynamics']['unique_host_id_name'],

    controller_host: controller['host'],
    controller_port: controller['port'],
    controller_ssl: controller['ssl'],
    controller_user: controller['user'],
    controller_accesskey: controller['accesskey'],

    http_proxy_host: http_proxy['host'],
    http_proxy_port: http_proxy['port'],
    http_proxy_user: http_proxy['user'],
    http_proxy_password_file: http_proxy['password_file']
  )
  notifies :restart, 'service[appdynamics_machine_agent]', :delayed
end

service 'appdynamics_machine_agent' do
  supports [:start, :stop, :restart]
  action [:enable, :start]
end
