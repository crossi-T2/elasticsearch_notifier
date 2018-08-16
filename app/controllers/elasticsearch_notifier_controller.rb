require 'rubygems'
require 'json'

class ElasticsearchNotifierController < ApplicationController

  def self.send_issue_update(user, context)

    u = {"email" => user.mail, "firstname" => user.firstname, "lastname" => user.lastname}
    
    changes = []

    context[:journal].details.each do |j|
      changes.push({
        "property"  => j.prop_key,
        "value"     => j.value,
        "old_value" => j.old_value
      })
    end

    post_to_server({
        "type"       => "issue",
        "action"     => "update",
        "user"       => u.to_json,
        "issue_id"   => context[:issue].id,
        "updated_on" => context[:issue].updated_on,
        "notes"      => context[:journal].notes,
        "changes"    => changes.to_json
    })

  end

  def self.send_issue_create(user, context)

    u = {
      "email"     => user.mail,
      "firstname" => user.firstname,
      "lastname"  => user.lastname
    }

    info = {
        "type"   => "issue",
        "action" => "create",
        "user"   => u.to_json
    }

    data = JSON.parse(info.to_json).merge(JSON.parse(context[:issue].to_json))

    # renaming id to avoid confusion with Elasticsearch's _id field
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-id-field.html
    data[:issue_id] = data.delete("id")

    post_to_server(JSON.dump(data))
  end
private
  def self.elasticsearch_rest_endpoint()
    return Setting.plugin_elasticsearch_notifier['elasticsearch_rest_endpoint']
  end

  def self.post_to_server(data)
    Rails.logger.info("ELASTICSEARCH_NOTIFIER: Posting entry to " + self.elasticsearch_rest_endpoint + ": " + data.to_json)
  end
end
