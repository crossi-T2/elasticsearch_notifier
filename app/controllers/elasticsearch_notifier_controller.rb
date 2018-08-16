require 'rubygems'
require 'uri'
require 'net/http'
require 'json'

class ElasticsearchNotifierController < ApplicationController

  def self.send_issue_create(user, context)

    u = {
      "email"     => user.mail,
      "firstname" => user.firstname,
      "lastname"  => user.lastname
    }

    info = {
        "resource" => "issue",
        "action"   => "create",
        "user"     => u.to_json
    }

    data = JSON.parse(info.to_json).merge(JSON.parse(context[:issue].to_json))

    # renaming 'id' to 'issue_id' in order to avoid confusion with Elasticsearch's _id field
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-id-field.html
    data[:issue_id] = data.delete("id")

    post_to_server(JSON.dump(data))
  end
  
  def self.send_issue_update(user, context)

    u = {
      "email"     => user.mail,
      "firstname" => user.firstname,
      "lastname"  => user.lastname
    }
    
    changes = []

    context[:journal].details.each do |j|
      changes.push({
        "property"  => j.prop_key,
        "value"     => j.value,
        "old_value" => j.old_value
      })
    end

    post_to_server({
        "resource"   => "issue",
        "action"     => "update",
        "user"       => u.to_json,
        "issue_id"   => context[:issue].id,
        "updated_on" => context[:issue].updated_on,
        "notes"      => context[:journal].notes,
        "changes"    => changes.to_json
    })

  end
private
  def self.elasticsearch_rest_endpoint()
    return Setting.plugin_elasticsearch_notifier['elasticsearch_rest_endpoint']
  end

  def self.post_to_server(data)
    uri = URI(self.elasticsearch_rest_endpoint)

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request.body = data.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")

    response = http.request(request)

    Rails.logger.info("ELASTICSEARCH_NOTIFIER: Elasticsearch's server response " + response.body)
  end
end
