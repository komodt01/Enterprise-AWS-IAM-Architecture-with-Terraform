data "aws_iam_policy_document" "department_abac" {
  statement {
    sid    = "AllowDepartmentMatchedResources"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageDepartmentTaggedInstances"
    effect = "Allow"

    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]

    resources = ["arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Department"
      values   = ["$${aws:PrincipalTag/Department}"]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Environment"
      values   = ["$${aws:PrincipalTag/Environment}"]
    }
  }
}

resource "aws_iam_policy" "department_abac" {
  name        = "DepartmentABAC-${var.environment}"
  description = "Demonstrates attribute-based access to EC2 instances using principal and resource tags"
  policy      = data.aws_iam_policy_document.department_abac.json
}

resource "aws_iam_role_policy_attachment" "department_abac" {
  role       = aws_iam_role.security_architect.name
  policy_arn = aws_iam_policy.department_abac.arn
}
