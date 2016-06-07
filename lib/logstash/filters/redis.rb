# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# A general search and replace tool which queries replacement values from a redis instance.
#
# This is actually a redis version of a translate plugin. <https://www.elastic.co/guide/en/logstash/current/plugins-filters-translate.html>
#
# Operationally, if the event field specified in the "field" configuration
# matches the EXACT contents of a redis key, the field's value will be substituted
# with the matched key's value from the redis GET <key> command.
#
# By default, the redis filter will replace the contents of the 
# matching event field (in-place). However, by using the "destination"
# configuration item, you may also specify a target event field to
# populate with the new translated value.
# 
# Alternatively, for simple string search and replacements for just a few values
# you might consider using the gsub function of the mutate filter.

class LogStash::Filters::Redis < LogStash::Filters::Base

  config_name "redis"

  # The hostname of your Redis server.
  config :host, :validate => :string, :default => "127.0.0.1"

  # The port to connect on.
  config :port, :validate => :number, :default => 6379

  # Password to authenticate with. There is no authentication by default.
  config :password, :validate => :password

  # The Redis database number.
  config :db, :validate => :number, :default => 0
  
  # The name of the logstash event field containing the value to be compared for a
  # match by the translate filter (e.g. "message", "host", "response_code"). 
  # 
  # If this field is an array, only the first value will be used.
  config :field, :validate => :string, :required => true

  # If the destination (or target) field already exists, this configuration item specifies
  # whether the filter should skip translation (default) or overwrite the target field
  # value with the new translation value.
  config :override, :validate => :boolean, :default => false

  # The destination field you wish to populate with the translated code. The default
  # is a field named "redis". Set this to the same value as source if you want
  # to do a substitution, in this case filter will allways succeed. This will clobber
  # the old value of the source field! 
  config :destination, :validate => :string, :default => "redis"

  # In case no translation occurs in the event (no matches), this will add a default
  # translation string, which will always populate "field", if the match failed.
  #
  # For example, if we have configured `fallback => "no match"`, using this dictionary:
  #
  #     foo: bar
  #
  # Then, if logstash received an event with the field `foo` set to "bar", the destination
  # field would be set to "bar". However, if logstash received an event with `foo` set to "nope",
  # then the destination field would still be populated, but with the value of "no match".
  config :fallback, :validate => :string

  # Connection timeout
  config :timeout, :validate => :number, :required => false, :default => 5

  public
  def register
    require 'redis'
    require 'json'
    @redis = nil
  end # def register

  public
  def filter(event)
    return unless event.include?(@field)
    return if event.include?(@destination) and not @override

    source = event[@field].is_a?(Array) ? event[@field].first.to_s : event[@field].to_s
    @redis ||= connect
    val = @redis.get(source)
    if val
      begin
        event[@destination] = JSON.parse(val)
      rescue JSON::ParserError => e
        event[@destination] = val
      end
    elsif @fallback
      event[@destination] = @fallback
    end
      
    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter

  private
  def connect
     Redis.new(
       :host => @host,
       :port => @port, 
       :timeout => @timeout,
       :db => @db,
       :password => @password.nil? ? nil : @password.value
     )
  end #def connect
end # class LogStash::Filters::Redis
