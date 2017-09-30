Gem::Specification.new do |s|

  s.name = 'logstash-filter-redis'
  s.version = '0.3.0'
  s.licenses = ['Apache-2.0']
  s.summary = "This filter allows the storage of event fields in a redis key to be retrieved by a later event"
  s.description = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["meulop","make"]
  s.email = 'markus.paaso@gmail.com'
  s.homepage = "https://github.com/make/logstash-redis-filter"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency "redis", '>= 3.0.0', '< 4.0.0'

  s.add_development_dependency 'logstash-devutils', "= 1.1.0"
end

