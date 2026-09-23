terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region used by the provider"
  type        = string
  default     = "us-east-1"
}

data "aws_organizations_organization" "current" {}

data "aws_iam_policy_document" "region_guardrail" {
  statement {
    sid    = "DenyActionsOutsideApprovedRegions"
    effect = "Deny"

    not_actions = [
      "iam:*",
      "organizations:*",
      "route53:*",
      "cloudfront:*",
      "support:*"
    ]

    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1", "us-west-2"]
    }
  }
}

resource "aws_organizations_policy" "region_guardrail" {
  name        = "ApprovedRegionsGuardrail"
  description = "Example SCP restricting regional AWS activity to approved regions"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.region_guardrail.json
}
