# Changelog

Notable changes to this plugin are documented in this file. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## 0.1.0 - 2026-08-01

First release of the [Flokart World fork](https://github.com/flokart-world/redmine_omniauth_saml).
Changes are relative to commit `b102cb51dc293a38aa0c5ebfe8d16aaecf52bec3`
("Merge pull request #44"), the last upstream commit this fork branched
from.

### Changed

- Redmine 6.0 or higher is now required; earlier Redmine series have
  reached end of life and are no longer supported.
- Migrated to OmniAuth 2: the plugin now depends on omniauth 2.x,
  omniauth-saml 2.x, ruby-saml 1.18 and omniauth-rails_csrf_protection.
  This was required because Redmine 6 ships Rack 3, which the previous
  gem set cannot run on.
- The configuration module was renamed: initializers written for the
  upstream plugin must call `RedmineOmniauthSaml::Base.configure` instead
  of `Redmine::OmniAuthSAML::Base.configure`.
- The "Login with SAML" link on the sign-in page became a button that
  submits a POST form, as OmniAuth 2 only accepts POST to start the
  authentication flow. Visiting `/auth/saml` with GET still works: a
  bridge page re-enters the flow automatically.
- `/auth/<provider>` URLs for providers other than `saml` now return
  404 instead of being silently accepted.
- The plugin registration now points at this fork and reports version
  0.1.0. The stale donation link was removed from the README.

### Fixed

- The SAML metadata endpoint (`/saml/metadata`) crashed with an internal
  server error on every request; it now serves the SP metadata XML.
- A failed login attempt displayed a "Translation missing" placeholder
  instead of the invalid-credentials message.
- The sample initializer raised a `NameError` at application start when
  copied as documented; it now works as shipped, and its example values
  no longer point at a real third-party identity provider.
- The install instructions wrongly claimed the plugin has no database
  migration.

### Added

- An integration test suite covering the login flow, on-the-fly user
  creation, logout paths and the metadata endpoint.
- A GitHub Actions workflow running the suite against the supported
  Redmine stable branches with MariaDB 10.11, also runnable locally
  with [act](https://github.com/nektos/act).

### Known issues

- SP-initiated single logout (used when `signout_url` is configured)
  sends a wrong NameID to the identity provider. Deployments leaving
  `signout_url` empty are unaffected.
