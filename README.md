
# <application_license_badge>
<!--- [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](./LICENSE) --->

# BC Gov Terraform Template

This repo provides a starting point for users who want to create valid Terraform modules stored in GitHub.  

## Third-Party Products/Libraries used and the licenses they are covered by
<!--- product/library and path to the LICENSE --->
<!--- Example: <library_name> - [![GitHub](<shield_icon_link>)](<path_to_library_LICENSE>) --->

## Project Status

- [x] Development
- [ ] Production/Maintenance

# Documentation

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## References

The steps here are partially based on those in [this](https://scandiweb.com/blog/sign-in-to-amazon-aws-using-saml-protocol-and-keycloak-as-identity-provider/) article:

## Getting Started

### Pre-requisites

#### KeyCloak

* `realm-admin` access to the KeyCloak realm where the configuration objects will be created

### AWS

* admin-type access with access key to an AWS account where the SAML configuration objects will be created

### Initial Steps

Prior to executing the automation code, there are a few steps (below) that must be completed manually.   

* Create a KeyCloak OIDC client that will be used by Terraform to perform its automations.  This should have the following values on the "Settings" tab:
    * Access-type: `confidential`
    * Standard Flow Enabled: `Off`
    * Implicit Flow Enabled: `Off`
    * Direct Access Grants Enabled: `Off`
    * Service Accounts Enabled: `On`
* Capture and save the `Secret` token from the `Credentials` tab of the client created above. It will be used as the keycloak access key by terraform.
* Grant the `realm-admin` or similar role to the service account you've just created via Clients -> <Your Client> -> Service Account Roles -> Client Roles  

* retrieve the AWS-provided SAML metadata file [here](https://signin.aws.amazon.com/static/saml-metadata.xml) and save to your workstation.
* In the KeyCloak realm, create a new SAML client
* Import the AWS-provided SAML metadata file, which will pre-populate most to the client configuration value.
* Modify the `Base URL` field so it looks like: `/auth/realms/<your_realm_name>/protocol/saml/clients/amazon-aws`
* Modify the `IDP Initiated SSO URL Name` field so it has the value `amazon-aws`.
* Modify `Name ID Format` so it has the value `persistent`

* If you happen to have deployed `aws-login` before confoguing KeyCloak and AWS roles (which is fine) you can also edit the following with the url spit out by aws-login deployment:
- Valid Redirect URIs (add it to the default)
- Fine Grain SAML Endpoint Configuration -> Assertion Consumer Service Post Binding URL

* Save the client configuration
* In the "Scope" tab for the client you just created, set "Full Scope Allowed" to "Off"

You'll need the following values for the automation code:
- Client ID/GUID of the SAML client you created above (grab from URL)
- Service Account key from Client -> Crednetials tab of the Terraform automation client you created above
- The realm name
- The base url of the KeyCloak server


## Getting Help or Reporting an Issue
<!--- Example below, modify accordingly --->
To report bugs/issues/feature requests, please file an [issue](../../issues).


## How to Contribute
<!--- Example below, modify accordingly --->
If you would like to contribute, please see our [CONTRIBUTING](./CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](./CODE_OF_CONDUCT.md). 
By participating in this project you agree to abide by its terms.


## License
<!--- Example below, modify accordingly --->
    Copyright 2018 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
