lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'

if RUBY_VERSION < '0.0.1'
  require 'sensu-plugins-oracle'
else
  require_relative 'lib/sensu-plugins-oracle'
end

Gem::Specification.new do |s|
  s.authors = ['Sensu-Plugins and contributors']

  s.date = Date.today.to_s
  s.description = 'This plugin provides native Oracle instrumentation.'
  s.email = '<thomas.steiner@ikey.ch>'
  s.executables = Dir.glob('bin/**/*.rb').map { |file| File.basename(file) }
  s.files = Dir.glob('{bin,lib}/**/*') + %w(LICENSE README.md CHANGELOG.md)
  s.homepage = 'https://github.com/thomis/sensu-plugins-oracle'
  s.license = 'MIT'
  s.metadata = { 'maintainer' => 'thomis',
                 'development_status' => 'active',
                 'production_status'  => 'unstable - testing recommended',
                 'release_draft'      => 'false',
                 'release_prerelease' => 'false' }
  s.name = 'sensu-plugins-oracle'
  s.platform = Gem::Platform::RUBY
  s.post_install_message = 'You can use the embedded Ruby by setting' \
                           ' EMBEDDED_RUBY=true in /etc/default/sensu'
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 1.9.3'

  s.summary = 'Sensu plugins for oracle'
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.version = SensuPluginsOracle::Version::VER_STRING

  s.add_runtime_dependency 'sensu-plugin', '~> 2.3.0'
  s.add_runtime_dependency 'ruby-oci8', '~> 2.2.4.1'
  s.add_runtime_dependency 'dentaku', '~> 3.0.0'

  s.add_development_dependency 'bundler', '~> 1.16.0'
  s.add_development_dependency 'rake', '~> 12.2.1'
  s.add_development_dependency 'pry',  '~> 0.11.1'
  s.add_development_dependency 'rspec', '~> 3.7.0'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0.8'
end
