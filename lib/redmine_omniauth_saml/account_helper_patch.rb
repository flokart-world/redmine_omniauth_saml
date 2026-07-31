require_dependency 'account_helper'

module RedmineOmniauthSaml
  module AccountHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def label_for_saml_login
        RedmineOmniauthSaml.label_login_with_saml.presence || l(:label_login_with_saml)
      end

      # Keeps the provider knowledge out of the views: both the login-page
      # button and the GET-to-POST interstitial target this same URL.
      def saml_request_phase_path(origin = nil)
        sign_in_path(:provider => PROVIDER, :origin => origin)
      end
    end
  end
end

unless AccountHelper.included_modules.include? RedmineOmniauthSaml::AccountHelperPatch
  AccountHelper.send(:include, RedmineOmniauthSaml::AccountHelperPatch)
end
