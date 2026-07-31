require File.expand_path('../../test_helper', __FILE__)

class RedmineOmniauthSamlTest < ActiveSupport::TestCase
  include RedmineOmniauthSaml::TestHelper

  setup do
    setup_saml
  end

  teardown do
    teardown_saml
  end

  test "PROVIDER names the registered strategy" do
    assert_equal 'saml', RedmineOmniauthSaml::PROVIDER
  end

  test "enabled? follows the plugin setting" do
    assert RedmineOmniauthSaml.enabled?
    setup_saml('enabled' => false)
    assert_not RedmineOmniauthSaml.enabled?
  end

  test "onthefly_creation? requires the plugin to be enabled" do
    setup_saml('onthefly_creation' => true)
    assert RedmineOmniauthSaml.onthefly_creation?
    setup_saml('enabled' => false, 'onthefly_creation' => true)
    assert_not RedmineOmniauthSaml.onthefly_creation?
  end

  test "user_attributes_from_saml resolves the configured attribute mapping" do
    omniauth = OmniAuth::AuthHash.new(
      :extra => {
        :raw_info => {
          :username  => "jdoe",
          :email     => "jdoe@example.net",
          :firstname => "John",
          :lastname  => "Doe"
        }
      }
    )
    attributes = RedmineOmniauthSaml.user_attributes_from_saml(omniauth)
    assert_equal "jdoe", attributes[:login]
    assert_equal "jdoe@example.net", attributes[:mail]
    assert_equal "John", attributes[:firstname]
    assert_equal "Doe", attributes[:lastname]
  end

  test "user_attributes_from_saml resolves mappings of arbitrary depth" do
    RedmineOmniauthSaml::Base.saml = RedmineOmniauthSaml::TEST_SAML_SETTINGS.merge(
      :attribute_mapping => {
        :login      => 'one.two.three.four.levels.username',
        :mail       => 'one.two.three.four.levels.email',
        :firstname  => 'one.two.three.four.levels.firstname',
        :lastname   => 'one.two.three.four.levels.lastname'
      }
    )
    omniauth = OmniAuth::AuthHash.new(
      :one => {
        :two => {
          :three => {
            :four => {
              :levels => {
                :username  => "jdoe",
                :email     => "jdoe@example.net",
                :firstname => "John",
                :lastname  => "Doe"
              }
            }
          }
        }
      }
    )
    attributes = RedmineOmniauthSaml.user_attributes_from_saml(omniauth)
    assert_equal "jdoe", attributes[:login]
    assert_equal "jdoe@example.net", attributes[:mail]
    assert_equal "John", attributes[:firstname]
    assert_equal "Doe", attributes[:lastname]
  end
end
