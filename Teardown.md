# Terraform Teardown Guide

## Purpose

This document describes how to remove resources created by the Terraform configurations in this repository.

The project contains two independent Terraform configurations:

```text
terraform/
├── iam/
└── org/
```

They should be reviewed and managed separately because they operate at different security and governance scopes.

---

## Important

Terraform destruction can permanently remove AWS security resources.

Before running `terraform destroy`:

- Confirm the AWS account and active identity
- Review the Terraform plan
- Confirm the resources belong to this project
- Verify that no workloads or users depend on the IAM role or policies
- Review organization-level resources separately from account-level IAM resources

Do not run destructive commands against an AWS environment without understanding their impact.

---

## Verify AWS Identity

Before performing Terraform operations, confirm the AWS identity being used:

```bash
aws sts get-caller-identity
```

Verify that the returned account is the intended AWS account.

---

# IAM Teardown

The IAM implementation is located in:

```text
terraform/iam/
```

It contains:

- Security Architect IAM role
- Role trust policy
- Read-oriented IAM permissions policy
- Department/environment ABAC policy
- Policy attachments

---

## Initialize Terraform

Navigate to the IAM configuration:

```bash
cd terraform/iam
```

Initialize the working directory:

```bash
terraform init
```

---

## Review Current State

If the configuration has previously been deployed using the current Terraform state, inspect the managed resources:

```bash
terraform state list
```

You can also review the configuration and current state with:

```bash
terraform show
```

---

## Create a Destruction Plan

Before deleting anything, generate a destruction plan:

```bash
terraform plan -destroy
```

Review the output carefully.

Expected resources may include:

```text
aws_iam_role.security_architect
aws_iam_policy.security_architect
aws_iam_policy.department_abac
aws_iam_role_policy_attachment.security_architect
aws_iam_role_policy_attachment.department_abac
```

The exact plan should be treated as the authoritative source for what Terraform intends to remove.

---

## Destroy IAM Resources

After reviewing the plan:

```bash
terraform destroy
```

Terraform will display the proposed changes and request confirmation before proceeding.

Avoid `-auto-approve` for security-sensitive teardown unless automation requirements and safeguards have been deliberately designed.

---

## Verify IAM Removal

After Terraform completes, verify that the resources are no longer managed:

```bash
terraform state list
```

You can also verify relevant AWS resources using the AWS CLI.

For example:

```bash
aws iam get-role --role-name SecurityArchitect-development
```

If the role was successfully removed, AWS should return a `NoSuchEntity` response.

Environment-specific role names may differ depending on the Terraform variable values used during deployment.

---

# AWS Organizations Teardown

The organization-level Terraform configuration is located in:

```text
terraform/org/
```

This configuration defines the regional Service Control Policy:

```text
ApprovedRegionsGuardrail
```

The current project intentionally does **not** attach the SCP to an organizational unit or AWS account.

---

## Organization-Level Caution

SCPs operate at an AWS Organizations governance layer and can affect permissions across multiple accounts when attached.

Always verify the organization and policy status before modifying or deleting organization-level controls.

Confirm the current AWS identity:

```bash
aws sts get-caller-identity
```

If appropriate, inspect the organization:

```bash
aws organizations describe-organization
```

---

## Initialize the Organizations Configuration

Navigate to:

```bash
cd terraform/org
```

Initialize Terraform:

```bash
terraform init
```

---

## Review the Destruction Plan

Run:

```bash
terraform plan -destroy
```

The expected managed resource is the SCP definition:

```text
aws_organizations_policy.region_guardrail
```

Review the Terraform output before proceeding.

---

## Verify SCP Attachments

Although this repository does not configure an SCP attachment, verify the current AWS environment before deleting an organization policy.

For example:

```bash
aws organizations list-targets-for-policy \
  --policy-id <policy-id>
```

If a policy has been attached manually or by another process, investigate that dependency before attempting removal.

Do not assume that the current repository represents every change that may have occurred in the AWS environment.

---

## Destroy the SCP Definition

If the Terraform plan is correct and the policy has no required external dependencies:

```bash
terraform destroy
```

Review the proposed action before confirming destruction.

---

# Terraform State

Terraform relies on state to map configuration resources to deployed infrastructure.

This repository intentionally excludes local state files from Git:

```text
*.tfstate
*.tfstate.*
```

If the project was deployed using local state, retain the state until teardown has been successfully completed and verified.

Deleting Terraform state **before** destroying infrastructure does not delete the AWS resources. It only removes Terraform's record of those resources.

---

## If Terraform State Is Missing

Do not assume the AWS resources no longer exist simply because Terraform state is unavailable.

Use AWS tooling to determine whether relevant resources still exist.

Examples:

```bash
aws iam list-roles
```

```bash
aws iam list-policies --scope Local
```

```bash
aws organizations list-policies \
  --filter SERVICE_CONTROL_POLICY
```

If resources exist but are no longer represented in Terraform state, determine whether they should be imported, managed manually, or left in place before taking destructive action.

---

# Post-Teardown Validation

After teardown, verify both Terraform and AWS state.

For IAM:

```bash
cd terraform/iam
terraform state list
```

For Organizations:

```bash
cd terraform/org
terraform state list
```

Also verify the relevant AWS resources directly.

The objective is to confirm:

```text
Terraform no longer manages the resources
                +
AWS no longer contains the resources intended for removal
```

---

## Security Considerations

Teardown is part of the security lifecycle.

Removing IAM resources should account for:

- Active role sessions
- External dependencies
- Manually created policy attachments
- Resources created outside Terraform
- Organization-level policy dependencies
- Terraform state integrity
- Audit requirements

In a production environment, destructive infrastructure changes would normally be governed through change management, peer review, approvals, logging, and recovery procedures.

Those governance processes are outside the scope of this repository.

---

## Current Project Scope

This guide applies only to resources represented by the current Terraform implementation.

It does not assume the existence of:

- Makefile automation
- Terraform remote-state buckets
- Automated compliance reports
- Cleanup scripts
- CI/CD pipelines
- Production workloads
- AWS Organizations OU structures

This keeps teardown instructions aligned with the implementation actually present in the repository.
