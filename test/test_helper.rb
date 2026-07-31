# Load the Redmine host application's test helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/support/saml_test_settings')

module RedmineOmniauthSaml
  module TestHelper
    def setup_saml(settings = {})
      # Assigned straight to Base.saml so the attribute mapping does not
      # depend on the host's initializer values.
      RedmineOmniauthSaml::Base.saml = TEST_SAML_SETTINGS
      Setting.plugin_redmine_omniauth_saml = {
        'enabled' => true,
        'onthefly_creation' => false,
        'label_login_with_saml' => '',
        'replace_redmine_login' => false
      }.merge(settings)
      # The per-request cache invalidation does not run outside of a request
      # cycle, so unit-level reads would otherwise see the previous value.
      Setting.clear_cache
      OmniAuth.config.test_mode = true
    end

    def teardown_saml
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:saml] = nil
    end

    def mock_saml_auth(username:, email:, firstname: 'Test', lastname: 'User')
      OmniAuth.config.mock_auth[:saml] = OmniAuth::AuthHash.new(
        :provider => 'saml',
        :uid => username,
        :extra => {
          :raw_info => {
            :username  => username,
            :email     => email,
            :firstname => firstname,
            :lastname  => lastname
          }
        }
      )
    end
  end
end
