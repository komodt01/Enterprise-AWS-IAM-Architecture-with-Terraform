data "aws_iam_policy_document" "security_architect_permissions" {
  statement {
    sid    = "ReadIAMConfiguration"
    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListRoles",
      "iam:ListPolicies"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ReadAccountIdentity"
    effect = "Allow"

    actions = [
      "sts:GetCallerIdentity"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "security_architect" {
  name        = "SecurityArchitectReadOnly-${var.environment}"
  description = "Read-only IAM visibility for the security architecture demonstration"
  policy      = data.aws_iam_policy_document.security_architect_permissions.json
}

resource "aws_iam_role_policy_attachment" "security_architect" {
  role       = aws_iam_role.security_architect.name
  policy_arn = aws_iam_policy.security_architect.arn
}
