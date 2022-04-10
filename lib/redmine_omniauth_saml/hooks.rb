module RedmineOmniauthSaml
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_account_login_top, :partial => 'redmine_omniauth_saml/view_account_login_top'

    def after_plugins_loaded(_context = {})
      RedmineOmniauthSaml.install_patches! if Rails.version >= '6.0'
    end
  end
end
