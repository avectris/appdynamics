%w(conf logs).each do |dir|
  describe file(['/opt/appdynamics/javaagent/', dir].join) do
    it { should be_directory }
    it { should exist }
    its('mode') { should cmp '0755' }
    its('owner') { should eq 'vagrant' }
    its('group') { should eq 'vagrant' }
  end
end

describe file('/opt/appdynamics/javaagent/javaagent.jar') do
  it { should exist }
end

%w(external-services lib sdk sdk-plugins utils).each do |dir|
  describe file(['/opt/appdynamics/javaagent/', dir].join) do
    it { should be_directory }
    it { should exist }
  end
end

describe file('/opt/appdynamics/javaagent/conf/controller-info.xml') do
  its('mode') { should cmp '0600' }
  its('owner') { should eq 'vagrant' }
  its('group') { should eq 'vagrant' }
  its('content') { should match(%r{controller-port>443<\/controller-port>$}) }
  its('content') { should match(%r{controller-host>localhost<\/controller-host>$}) }
  its('content') { should match(%r{controller-ssl-enabled>true<\/controller-ssl-enabled>$}) }
  its('content') { should match(%r{account-name>controller-user<\/account-name>$}) }
  its('content') { should match(%r{account-access-key>ABCDEF1234567890<\/account-access-key>$}) }
  its('content') { should match(%r{application-name>tomcat<\/application-name>$}) }
  its('content') { should match(%r{tier-name>development<\/tier-name>$}) }
  its('content') { should match(%r{node-name>test-node<\/node-name>$}) }
end
