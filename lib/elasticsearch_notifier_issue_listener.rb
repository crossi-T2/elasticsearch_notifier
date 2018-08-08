require 'rubygems'

class ElasticsearchNotifierIssueListener < Redmine::Hook::Listener
  def controller_issues_edit_after_save(context={})
    if context[:issue]
      ElasticsearchNotifierController.send_issue_update(User.current, context[:issue].id, context[:issue].status,context[:journal], context)
    end
  end
end

