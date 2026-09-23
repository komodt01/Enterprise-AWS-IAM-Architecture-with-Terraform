data "aws_iam_policy_document" "security_architect_assume_role" {
  statement {
    sid     = "AllowAccountPrincipals"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "security_architect" {
  name = "SecurityArchitect-${var.environment}"

  assume_role_policy = data.aws_iam_policy_document.security_architect_assume_role.json

  tags = {
    Department  = var.department
    Environment = var.environment
    Purpose     = "SecurityArchitecture"
  }
}
