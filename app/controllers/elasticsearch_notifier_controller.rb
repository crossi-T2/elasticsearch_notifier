require 'rubygems'
require 'json'

class ElasticsearchNotifierController < ApplicationController

  def self.send_issue_update(user, context)

    u = {"email" => user.mail, "firstname" => user.firstname, "lastname" => user.lastname}
    
    changes = []

    context[:journal].details.each do |j|
      changes.push({
        "property" => j.prop_key,
        "old_value" => j.old_value,
        "value" => j.value
      })
    end

    post_to_server({
        "type"    => "issue",
        "action"  => "update",
        "user"    => u.to_json,
        "id"      => context[:issue].id,
        "notes"   => context[:journal].notes,
        "changes" => changes.to_json,
    })

  end
private
  def self.elasticsearch_rest_endpoint()
    return Setting.plugin_elasticsearch_notifier['elasticsearch_rest_endpoint']
  end
  def self.post_to_server(data)
    Rails.logger.info("ELASTICSEARCH_NOTIFIER: Posting entry to " + self.elasticsearch_rest_endpoint + ": " + data.to_json)
  end
end
