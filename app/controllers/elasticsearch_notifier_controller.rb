require 'rubygems'
require 'json'

class ElasticsearchNotifierController < ApplicationController

  def self.send_issue_update(user, issueId, status, journal, context)
    changes = []
    journal.details.each do |j|
      changes.push({
        "property" => j.prop_key,
        "value" => j.value
      })
    end
    u = {"email" => user.mail, "firstname" => user.firstname, "lastname" => user.lastname}
    post_to_server({
        "type" => "issue",
        "user" => u.to_json,
        "issue" => issueId,
        "status" => status,
        "comment" => journal.notes,
        "changes" => changes.to_json,
    })

    context.each do |key, value|
      Rails.logger.info("ELASTICSEARCH_NOTIFIER: key " + key.to_s)
    end

    #Rails.logger.info("ELASTICSEARCH_NOTIFIER: Context " + context.inspect)
  end
private
  def self.elasticsearch_rest_endpoint()
    return Setting.plugin_elasticsearch_notifier['elasticsearch_rest_endpoint']
  end
  def self.post_to_server(data)
    Rails.logger.info("ELASTICSEARCH_NOTIFIER: Posting entry to " + self.elasticsearch_rest_endpoint + ": " + data.to_json)
  end
end
