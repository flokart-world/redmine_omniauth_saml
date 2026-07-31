# frozen_string_literal: true

module RedmineOmniauthSaml
  # Deterministic SAML configuration shared by the CI boot initializer
  # (test/support/saml_initializer.rb) and the test helper, so the booted
  # application and the test assertions cannot desynchronize.
  TEST_SAML_SETTINGS = {
    :assertion_consumer_service_url => "http://www.example.com/auth/saml/callback",
    :issuer                         => "http://www.example.com/saml/metadata",
    :single_logout_service_url      => "http://www.example.com/auth/saml/sls",
    :idp_sso_target_url             => "http://idp.example.com/saml2/idp/SSOService.php",
    :idp_cert_fingerprint           => "9E:65:2E:03:06:8D:80:F2:86:C7:6C:77:A1:D9:14:97:0A:4D:F4:4D",
    :name_identifier_format         => "urn:oasis:names:tc:SAML:2.0:nameid-format:transient",
    :idp_slo_target_url             => "http://idp.example.com/saml2/idp/SingleLogoutService.php",
    :name_identifier_value          => "mail",
    # freeze is shallow, so the nested hash needs its own.
    :attribute_mapping              => {
      :login      => 'extra.raw_info.username',
      :mail       => 'extra.raw_info.email',
      :firstname  => 'extra.raw_info.firstname',
      :lastname   => 'extra.raw_info.lastname'
    }.freeze
  }.freeze
end
