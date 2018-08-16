require 'rubygems'

class ElasticsearchNotifierIssueListener < Redmine::Hook::Listener
  def controller_issues_new_after_save(context={})
    if context[:issue]
      ElasticsearchNotifierController.send_issue_create(User.current, context)
    end
  end
  def controller_issues_edit_after_save(context={})
    if context[:issue]
      ElasticsearchNotifierController.send_issue_update(User.current, context)
    end
  end

end

