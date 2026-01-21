locals {
  public_client_built_in_redirect_uris = [
    "https://login.microsoftonline.com/common/oauth2/nativeclient",
    "https://login.live.com/oauth20_desktop.srf",
    "msal${azuread_application_registration.this.client_id}://auth",
    "ms-appx-web://microsoft.aad.brokerplugin/${azuread_application_registration.this.client_id}"
  ]
}