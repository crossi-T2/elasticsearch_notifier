require_dependency 'elasticsearch_notifier_issue_listener'


Redmine::Plugin.register :elasticsearch_notifier do
  name 'Elasticsearch Notifier plugin'
  author 'Cesare Rossi'
  description 'This is a plugin for Redmine to notify issue to Elasticsearch'
  version '0.1'
  url 'https://github.com/Terradue/elasticsearch_notifier'
  author_url 'https://github.com/crossi-T2'

  settings :default => {'elasticsearch_rest_endpoint' => "http://localhost:9200"}, :partial => 'settings/elasticsearch_notifier'

end
