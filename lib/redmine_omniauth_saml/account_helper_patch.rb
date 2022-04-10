require_dependency 'account_helper'

module RedmineOmniauthSaml
  module AccountHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
      end
    end

    module InstanceMethods
      def label_for_saml_login
        RedmineOmniauthSaml.label_login_with_saml.presence || l(:label_login_with_saml)
      end
    end
  end
end

unless AccountHelper.included_modules.include? RedmineOmniauthSaml::AccountHelperPatch
  AccountHelper.send(:include, RedmineOmniauthSaml::AccountHelperPatch)
end
