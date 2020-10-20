terraform {
	required_providers {
		keycloak = {
			source = "mrparkers/keycloak"
			version = ">= 2.0.0"
		}
		aws = {
			source = "hashicorp/aws"
			version = "3.11.0"
		}
	}
}

provider "http" {
	version = "2.0.0"
}

data "keycloak_realm" "kc-lz-sso-realm" {
	realm = var.kc_realm
}

// Note: we need to use the http data source over the keycloak provider's `keycloak_saml_client_installation_provider` because recent versions of KeyCloak such as ours don't expose the descriptor in the same way as prior versions.
data "http" "saml_idp_descriptor" {
	url = "${var.kc_base_url}/auth/realms/${var.kc_realm}/protocol/saml/descriptor"
}

resource "aws_iam_saml_provider" "default" {
	name                   = var.aws_saml_idp_name
	saml_metadata_document = data.http.saml_idp_descriptor.body
}

resource "aws_iam_role" "admin_role" {

	for_each = var.account_roles
	name = each.key

	assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.aws_context.account_id}:saml-provider/BCGovKeyCloak"
      },
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "SAML:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role-policy-attach" {
	depends_on = [aws_iam_role.admin_role]
	for_each = var.account_roles

	role = each.key
	policy_arn = each.value
}

data aws_caller_identity "aws_context" {}

module "cloud_roles" {

	source = "github.com/BCDevOps/terraform-keycloak-role-group-simplification"

	realm = var.kc_realm
	iam_auth_client_id = var.kc_iam_auth_client_id

	//	module operates on a list of accounts.  this allows us to define a bunch of projects and get all the accounts created for them.
	accounts = [ {
		project_identifier = var.account_name
		project_name = var.account_name
		name = var.account_name
		environment = var.account_name
		account_number = data.aws_caller_identity.aws_context.account_id
	}]
	role_names = [for role,arn in var.account_roles : role]
}

