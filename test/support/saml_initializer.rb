# SAML settings for the CI test run, installed into config/initializers by
# .github/workflows/test.yml. Tests override Base.saml with their own values;
# this file only has to make the application boot with the OmniAuth
# middleware registered.
#
# Paths go through Rails.root because this file is executed from a copy in
# config/initializers, where relative requires would not resolve.
require Rails.root.join("plugins/redmine_omniauth_saml/lib/redmine_omniauth_saml").to_s
require Rails.root.join("plugins/redmine_omniauth_saml/test/support/saml_test_settings").to_s

RedmineOmniauthSaml::Base.configure do |config|
  config.saml = RedmineOmniauthSaml::TEST_SAML_SETTINGS
end
