terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 2.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "3.11.0"
    }
  }
}

//dropping this back in to allow for proper migration of resources deependent on it
provider "http" {

}

provider "external" {

}

data "keycloak_realm" "kc-lz-sso-realm" {
  realm = var.kc_realm
}

// more-or-less drop-in replacement for (broken-in-0.14) http provider
data "external" "saml_idp_descriptor" {
  program = ["${path.module}/bin/http_get.sh"]

  query = {
    url = "${var.kc_base_url}/auth/realms/${var.kc_realm}/protocol/saml/descriptor"
  }
}

resource "aws_iam_saml_provider" "default" {
  name                   = var.aws_saml_idp_name
  saml_metadata_document = tostring(data.external.saml_idp_descriptor.result.data)
}

resource "aws_iam_role" "admin_role" {

  for_each             = var.account_roles
  name                 = each.key
  max_session_duration = 21600
  permissions_boundary = aws_iam_policy.bcgov_perm_boundary.arn

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.aws_context.account_id}:saml-provider/${var.aws_saml_idp_name}"
      },
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "SAML:aud": ${jsonencode(var.trusted_login_sources)}
        }
      }
    }
  ]
}
EOF
}
resource "aws_iam_policy" "bcgov_perm_boundary" {
  name        = "BCGOV_Permission_Boundary"
  description = "Policy to restrict actions on BCGov Resources"
  policy      = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "*",
              "Effect": "Allow",
              "Resource": "*",
              "Sid": "AllowAdminAccess"
          },
          {
              "Action": "iam:*Provider",
              "Effect": "Deny",
              "Resource": "*",
              "Sid": "DenyPermBoundaryBCGovIDPAlteration"
          },
          {
              "Action": [
                  "iam:Create*",
                  "iam:Update*",
                  "iam:Delete*"
              ],
              "Effect": "Deny",
              "Resource": [
                  "arn:aws:iam::*:role/BCGOV*",
                  "arn:aws:iam::*:policy/BCGOV*"
              ],
              "Sid": "DenyPermBoundaryBCGovAlteration"
          }
      ]
    }
EOF
}

resource "aws_iam_role_policy_attachment" "role-policy-attach" {
  depends_on = [aws_iam_role.admin_role]
  for_each   = var.account_roles

  role       = each.key
  policy_arn = each.value
}

data "aws_caller_identity" "aws_context" {}

module "cloud_roles" {

  source = "github.com/BCDevOps/terraform-keycloak-role-group-simplification"

  realm              = var.kc_realm
  iam_auth_client_id = var.kc_iam_auth_client_id

  //	module operates on a list of accounts.  this allows us to define a bunch of projects and get all the accounts created for them.
  //	@todo fix this so it supports distinct values for each of hte attributes insttead of va.raccount_name for everything
  accounts = [{
    project_identifier = var.account_name
    project_name       = var.account_name
    name               = var.account_name
    environment        = var.account_name
    account_number     = data.aws_caller_identity.aws_context.account_id
  }]
  role_names = [for role, arn in var.account_roles : role]
  idp_name   = var.aws_saml_idp_name
}

