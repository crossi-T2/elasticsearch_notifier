require 'rubygems'
require 'uri'
require 'net/http'
require 'json'

class ElasticsearchNotifierController < ApplicationController

  def self.send_issue_create(user, context)
    begin
      info = {
        "resource" => "issue",
        "action"   => "create"
      }

      u = { 
        "user": {
          "email"     => user.mail,
          "firstname" => user.firstname,
          "lastname"  => user.lastname
        }
      }

      #TODO: map explicitely the issue's field, for robustness
   
      data = JSON.parse(info.to_json).merge(JSON.parse(context[:issue].to_json).merge(JSON.parse(u.to_json)))

      post_to_server(data)
    rescue StandardError => e
      Rails.logger.info e.class.to_s
      Rails.logger.info e.to_s
      Rails.logger.info e.backtrace.join("\n")
    end
  end
  
  def self.send_issue_update(user, context)
    begin
      u = {
        "user": {
          "email"     => user.mail,
          "firstname" => user.firstname,
          "lastname"  => user.lastname
        }
      }
 
      changes = []

      context[:journal].details.each do |j|
        changes.push({
          "property"  => j.prop_key,
          "value"     => j.value,
          "old_value" => j.old_value
        })
      end

      info = {
          "resource"   => "issue",
          "action"     => "update",
          "id      "   => context[:issue].id,
          "updated_on" => context[:issue].updated_on,
          "notes"      => context[:journal].notes
      }
 
      data = JSON.parse(info.to_json).merge(JSON.parse(changes.to_json).merge(JSON.parse(u.to_json)))

      post_to_server(data)
    rescue StandardError => e
      Rails.logger.info e.class.to_s
      Rails.logger.info e.to_s
      Rails.logger.info e.backtrace.join("\n")
    end
  end
private
  def self.elasticsearch_rest_endpoint()
    return Setting.plugin_elasticsearch_notifier['elasticsearch_rest_endpoint']
  end

  def self.post_to_server(data)
    begin
      uri = URI(self.elasticsearch_rest_endpoint)

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request.body = data.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")

      response = http.request(request)

      Rails.logger.info("ELASTICSEARCH_NOTIFIER: Payload " + data.to_json)
      Rails.logger.info("ELASTICSEARCH_NOTIFIER: Elasticsearch's response " + response.body)
      
      raise Net::HTTPBadResponse.new(response.body) if response.code.to_i < 200 || response.code.to_i > 299
    rescue StandardError => e
      Rails.logger.info e.class.to_s
      Rails.logger.info e.to_s
      Rails.logger.info e.backtrace.join("\n")
    end
  end
end
