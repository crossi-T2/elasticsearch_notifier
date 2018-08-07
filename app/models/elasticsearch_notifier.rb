require 'rubygems'
#require 'httpclient'
require 'json'

class ElasticsearchNotifier < ActiveRecord::Base
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

    #context.each do |key, value|
    #  Rails.logger.info("ELASTICSEARCH_NOTIFIER: key " + key.to_s)
    #end

    Rails.logger.info("ELASTICSEARCH_NOTIFIER: Context " + context.inspect)
  end
private
  def self.elasticsearch_rest_endpoint()
    return Setting.plugin_elasticsearch_notifier['elasticsearch_rest_endpoint']
  end
  def self.post_to_server(data)
  #  client = HTTPClient.new
    Rails.logger.info("ELASTICSEARCH_NOTIFIER: Posting entry to " + self.elasticsearch_rest_endpoint + ": " + data.to_json)
  #  Rails.logger.info("UPDATES_NOTIFIER: Posting entry to " + self.elasticsearch_rest_endpoint + ": " + data.to_json)
 #   res = client.post(self.elasticsearch_rest_endpoint, data)
   # Rails.logger.info("UPDATES_NOTIFIER: Response code from " + self.elasticsearch_rest_endpoint + ": " + res.status_code.to_s)
  #  return res
  end
end
