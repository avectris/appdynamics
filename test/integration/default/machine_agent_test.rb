describe package('unzip') do
  it { should be_installed }
end

describe file('/opt/appdynamics/machineagent/conf') do
  it { should be_directory }
  it { should exist }
  its('mode') { should cmp '0755' }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end

describe file('/opt/appdynamics/machineagent/run.sh') do
  it { should exist }
  its('mode') { should cmp '0744' }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
end

describe file('/opt/appdynamics/machineagent/machineagent.jar') do
  it { should exist }
end

%w(bin extensions lib local-scripts monitors monitorsLibs scripts).each do |dir|
  describe file(['/opt/appdynamics/machineagent/', dir].join) do
    it { should be_directory }
    it { should exist }
  end
end

describe file('/etc/init.d/appdynamics_machine_agent') do
  it { should exist }
  its('mode') { should cmp '0744' }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('content') { should match(%r{^INSTALL_DIR="/opt/appdynamics/machineagent"$}) }
  its('content') { should match(%r{^pid_file="/var/run/appdynamics_machine_agent.pid"$}) }
end

describe file('/opt/appdynamics/machineagent/conf/controller-info.xml') do
  its('mode') { should cmp '0600' }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('content') { should match(%r{controller-host>localhost<\/controller-host>$}) }
  its('content') { should match(%r{account-name>controller-user<\/account-name>$}) }
  its('content') { should match(%r{account-access-key>ABCDEF1234567890<\/account-access-key>$}) }
  its('content') { should match(%r{application-name>tomcat<\/application-name>$}) }
  its('content') { should match(%r{tier-name>development<\/tier-name>$}) }
  its('content') { should match(%r{node-name>test-node<\/node-name>$}) }
end

describe service('appdynamics_machine_agent') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
