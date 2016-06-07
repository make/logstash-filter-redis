require 'spec_helper'
require "logstash/filters/redis"
require "redis"
require "pp"
require "json"

describe LogStash::Filters::Redis do

  before(:all) do
    @redis = Redis.new()
    @redis.set("somekey", "somevalue")
  end

  describe "Retrieves data from redis" do
    config <<-CONFIG
      filter {
        redis {
          field => "redis-key"
          destination => "redis-value"
        }
      }
    CONFIG

    sample({"message" => "Test message", "redis-key" => "somekey"}) do
      insist { subject["redis-value"] } == "somevalue"
      insist { @redis.get("somekey") } == "somevalue"
    end
  end

  describe "Retrieves data from redis when field is an array" do
    config <<-CONFIG
      filter {
        redis {
          field => ["redis-key"]
          destination => "redis-value"
        }
      }
    CONFIG

    sample({"message" => "Test message", "redis-key" => "somekey"}) do
      insist { subject["redis-value"] } == "somevalue"
      insist { @redis.get("somekey") } == "somevalue"
    end
  end

end
