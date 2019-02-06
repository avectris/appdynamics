name 'appdynamics'
maintainer 'Roland Hansmann'
maintainer_email 'roland.hansmann@avectris.ch'
description 'Installs and configures AppDynamics Machine and/or Java Agent'
license 'AGPL-3.0'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

%w(redhat centos).each do |os|
  supports os
end

depends 'ark', '~> 1.1.0'

issues_url 'https://github.com/avectris/appdynamics/issues'
source_url 'https://github.com/avectris/appdynamics'
