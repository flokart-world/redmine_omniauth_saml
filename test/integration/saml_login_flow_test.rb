require File.expand_path('../../test_helper', __FILE__)

class SamlLoginFlowTest < ActionDispatch::IntegrationTest
  include RedmineOmniauthSaml::TestHelper

  fixtures :users, :email_addresses

  setup do
    setup_saml
  end

  teardown do
    teardown_saml
  end

  test "login page shows the SAML button as a POST form when enabled" do
    get "/login"
    assert_response :success
    assert_select "#saml-login form[action=?][method=post]", "/auth/saml" do
      assert_select "input[type=submit][value=?]", "Login with SAML"
    end
  end

  test "login page shows the configured custom label" do
    setup_saml('label_login_with_saml' => 'Corporate SSO')
    get "/login"
    assert_response :success
    assert_select "#saml-login input[type=submit][value=?]", "Corporate SSO"
  end

  test "login page hides the SAML button when disabled" do
    setup_saml('enabled' => false)
    get "/login"
    assert_response :success
    assert_select "#saml-login", 0
  end

  test "GET on the request phase renders the bridging interstitial" do
    get "/auth/saml"
    assert_response :success
    assert_select "form#saml-redirect-form[action=?][method=post]", "/auth/saml"
    assert_match "saml-redirect-form", response.body
  end

  test "the interstitial forwards the origin parameter" do
    get "/auth/saml", :params => {:origin => "/projects"}
    assert_response :success
    assert_select "form#saml-redirect-form[action=?]", "/auth/saml?origin=%2Fprojects"
  end

  test "POST on the request phase enters the OmniAuth flow" do
    post "/auth/saml"
    assert_redirected_to %r{/auth/saml/callback}
  end

  test "unregistered providers are rejected" do
    get "/auth/blah"
    assert_response :not_found
    post "/auth/blah"
    assert_response :not_found
  end

  test "callback logs in an existing user" do
    mock_saml_auth(:username => "jsmith", :email => "jsmith@somenet.foo")
    previous_login_on = User.find_by_login("jsmith").last_login_on
    post "/auth/saml/callback"
    assert_redirected_to "/my/page"
    follow_redirect!
    assert_response :success
    assert session[:logged_in_with_saml]
    assert_not_equal previous_login_on, User.find_by_login("jsmith").last_login_on
  end

  test "callback rejects an unknown user when on-the-fly creation is off" do
    mock_saml_auth(:username => "stranger", :email => "stranger@example.net")
    assert_no_difference "User.count" do
      post "/auth/saml/callback"
    end
    assert_redirected_to "/login"
    follow_redirect!
    assert_select "div.flash.error", :text => /Invalid user or password/
  end

  test "callback creates and logs in an unknown user when on-the-fly creation is on" do
    setup_saml('onthefly_creation' => true)
    mock_saml_auth(:username => "newcomer", :email => "newcomer@example.net", :firstname => "New", :lastname => "Comer")
    assert_difference "User.count", 1 do
      post "/auth/saml/callback"
    end
    assert_redirected_to "/my/page"
    user = User.find_by_login("newcomer")
    assert user.active?
    assert user.created_by_omniauth_saml
    assert_not user.change_password_allowed?
    assert_equal "newcomer@example.net", user.mail
    assert_equal "New", user.firstname
    assert_equal "Comer", user.lastname
  end

  test "logout of a SAML session logs the user out" do
    mock_saml_auth(:username => "jsmith", :email => "jsmith@somenet.foo")
    post "/auth/saml/callback"
    assert_redirected_to "/my/page"

    get "/logout"
    assert_redirected_to "/"

    get "/my/page"
    assert_redirected_to "/login?back_url=http%3A%2F%2Fwww.example.com%2Fmy%2Fpage"
  end

  test "logout with a configured signout URL redirects to the IdP single logout" do
    RedmineOmniauthSaml::Base.saml = RedmineOmniauthSaml::TEST_SAML_SETTINGS.merge(
      :signout_url => "http://idp.example.com/saml2/idp/SingleLogoutService.php?ReturnTo="
    )
    mock_saml_auth(:username => "jsmith", :email => "jsmith@somenet.foo")
    post "/auth/saml/callback"
    assert_redirected_to "/my/page"

    get "/logout"
    assert_response :redirect
    assert_match %r{\Ahttp://idp\.example\.com/saml2/idp/SingleLogoutService\.php}, response.headers["Location"]
  end

  test "logout without a SAML session is untouched by the plugin" do
    post "/login", :params => {:username => "jsmith", :password => "jsmith"}
    assert_redirected_to "/my/page"

    post "/logout"
    assert_redirected_to "/"

    get "/my/page"
    assert_redirected_to "/login?back_url=http%3A%2F%2Fwww.example.com%2Fmy%2Fpage"
  end

  test "the SLS endpoint logs the user out" do
    mock_saml_auth(:username => "jsmith", :email => "jsmith@somenet.foo")
    post "/auth/saml/callback"
    assert_redirected_to "/my/page"

    get "/auth/saml/sls"
    assert_redirected_to "/login"

    get "/my/page"
    assert_redirected_to "/login?back_url=http%3A%2F%2Fwww.example.com%2Fmy%2Fpage"
  end

  test "metadata endpoint serves the SP metadata when enabled" do
    get "/saml/metadata"
    assert_response :success
    assert_match %r{application/xml}, response.media_type
    assert_match "EntityDescriptor", response.body
    assert_match RedmineOmniauthSaml::TEST_SAML_SETTINGS[:issuer], response.body
  end

  test "metadata endpoint is not found when disabled" do
    setup_saml('enabled' => false)
    get "/saml/metadata"
    assert_response :not_found
  end
end
