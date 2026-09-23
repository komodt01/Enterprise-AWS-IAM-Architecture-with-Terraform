# Enterprise AWS IAM Architecture with Terraform

## Overview

This project demonstrates an AWS identity and access management architecture implemented with Terraform.

The focus is on several core IAM architecture patterns:

- Role-based access using AWS IAM roles
- Separation of role trust from role permissions
- Least-privilege authorization
- Attribute-Based Access Control (ABAC)
- Environment and department attributes
- AWS Organizations Service Control Policy (SCP) guardrails
- Separation of account-level IAM controls from organization-level governance

The project is intentionally scoped as an architecture implementation rather than a complete enterprise IAM platform.

---

## Architecture Objectives

The architecture addresses four primary identity and governance concerns.

### 1. Work Through Roles

Access is modeled through an IAM role rather than long-lived IAM user permissions.

The role contains an explicit trust policy defining who can assume the role.

### 2. Separate Authentication Trust from Authorization

The architecture separates:

```text
Who can assume the role
        |
        v
IAM Trust Policy

        +

What the role can do
        |
        v
IAM Permissions Policies
```

This distinction is fundamental to AWS IAM architecture.

### 3. Apply Least Privilege

The Security Architect role receives limited IAM visibility rather than broad administrative access.

The policy permits selected read operations such as:

```text
iam:GetRole
iam:GetPolicy
iam:GetPolicyVersion
iam:ListRoles
iam:ListPolicies
sts:GetCallerIdentity
```

The role is not granted general IAM write or administrative permissions.

### 4. Add Attribute-Based Authorization

ABAC demonstrates how access decisions can incorporate identity and resource attributes rather than relying entirely on individually defined role permissions.

---

## Architecture

```text
AWS Account
    |
    +-- IAM Role
    |      |
    |      +-- Trust Policy
    |      |      |
    |      |      +-- Controls who can assume the role
    |      |
    |      +-- Read-Only IAM Policy
    |      |      |
    |      |      +-- Limited IAM visibility
    |      |
    |      +-- ABAC Policy
    |             |
    |             +-- Department match
    |             +-- Environment match
    |
    +-- AWS Organizations
           |
           +-- Region Guardrail SCP
                  |
                  +-- Defines organization-level
                      regional restrictions
```

IAM and AWS Organizations controls are kept in separate Terraform configurations because they operate at different governance scopes.

---

## IAM Role Architecture

The Terraform configuration creates a `SecurityArchitect` role for the selected environment.

Example:

```text
SecurityArchitect-development
```

The role receives attributes including:

```text
Department  = engineering
Environment = development
Purpose     = SecurityArchitecture
```

These attributes provide identity context and support the ABAC example.

---

## Trust Policy

The role trust policy controls which AWS principals can request `sts:AssumeRole`.

The project uses the current AWS account as the trust boundary:

```hcl
principals {
  type        = "AWS"
  identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}
```

This establishes the account trust relationship but does not by itself grant principals permission to assume the role.

In a production architecture, the trust policy would normally be further constrained based on the organization's identity model, such as specific roles, federated identities, or additional policy conditions.

---

## Least-Privilege Permissions

The role receives a custom read-oriented IAM policy rather than a broad AWS-managed administrative policy.

The policy provides selected IAM visibility for architecture and security review while excluding general IAM modification privileges.

This demonstrates the principle:

```text
Grant the permissions required for the intended function
rather than granting broad administrative access.
```

---

## Attribute-Based Access Control

The project includes an ABAC policy demonstrating access based on matching principal and resource attributes.

The example permits EC2 start and stop operations only when the resource's attributes match the principal's attributes.

Conceptually:

```text
Principal Department
        =
Resource Department

AND

Principal Environment
        =
Resource Environment
```

Terraform implements the conditions using:

```text
aws:PrincipalTag/Department
ec2:ResourceTag/Department

aws:PrincipalTag/Environment
ec2:ResourceTag/Environment
```

This demonstrates how attributes can reduce reliance on large numbers of static role-specific policies.

---

## ABAC Example

The state-changing EC2 permissions are:

```text
ec2:StartInstances
ec2:StopInstances
```

and apply to EC2 instance resources only when both tag conditions match.

`ec2:DescribeInstances` is handled separately because the API does not provide the same resource-level authorization model for that action.

This separation demonstrates an important IAM design principle: policy structure must account for the authorization capabilities of the individual AWS API actions being controlled.

---

## AWS Organizations Guardrail

The project also contains a separate AWS Organizations Terraform configuration.

The example SCP defines a regional guardrail intended to deny applicable AWS actions outside:

```text
us-east-1
us-west-2
```

Selected global services are excluded from the regional deny logic.

The SCP is **defined but intentionally not attached** to an organizational unit or AWS account by this project.

That represents a governance boundary:

```text
Define Control
      |
      v
Review
      |
      v
Approve
      |
      v
Attach to OU / Account
      |
      v
Monitor Impact
```

Separating policy definition from enforcement reduces the risk of automatically applying an organization-wide restriction before its impact has been reviewed.

---

## Terraform Structure

```text
terraform/
├── iam/
│   ├── main.tf
│   ├── variables.tf
│   ├── roles.tf
│   ├── policies.tf
│   ├── abac.tf
│   └── outputs.tf
└── org/
    └── main.tf
```

### IAM Configuration

`terraform/iam/` contains:

- AWS provider configuration
- Environment variables
- Department attribute
- IAM role
- Role trust policy
- Least-privilege IAM permissions
- ABAC policy
- Policy attachments
- Terraform outputs

### Organizations Configuration

`terraform/org/` contains:

- AWS provider configuration
- Organizations discovery
- Regional SCP definition

The SCP is not automatically attached.

---

## Environment Separation

The IAM configuration supports:

```text
development
staging
production
```

Terraform validates the environment input before using it in resource configuration.

The selected environment is incorporated into IAM resource naming and identity attributes.

Example:

```text
SecurityArchitect-development
SecurityArchitect-staging
SecurityArchitect-production
```

---

## Security Design Decisions

### Roles Instead of Long-Lived IAM Users

Roles support temporary AWS credentials and provide a cleaner foundation for workforce federation and workload access patterns.

### Explicit Trust Policy

Trust relationships are modeled separately from authorization permissions.

### Custom Scoped Permissions

The architecture avoids attaching `AdministratorAccess` to the example role.

### Attribute-Based Authorization

Department and environment attributes demonstrate dynamic authorization based on identity and resource context.

### Organization Guardrails

SCPs provide a separate preventive-control layer above account-level IAM permissions.

### Controlled SCP Enforcement

The example SCP is defined without automatically attaching it to an organization target.

---

## Terraform State Protection

The repository excludes Terraform state and local variable files through `.gitignore`.

Excluded artifacts include:

```text
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
*.tfplan
.terraform/
```

Terraform state can contain infrastructure metadata and should not be casually committed to a public source repository.

Production implementations should use an appropriately secured remote state architecture with access controls, encryption, locking, and recovery protections.

---

## Deployment Status

The repository contains Terraform implementations for the documented IAM and SCP architecture.

The source code has been committed to demonstrate the architecture and control patterns.

The repository does **not currently claim that the Terraform has been successfully deployed or validated against an AWS environment**.

Before deployment, the configurations should be reviewed and tested using the normal Terraform workflow:

```bash
terraform fmt
terraform init
terraform validate
terraform plan
```

Organization-level controls should receive additional review before enforcement because SCPs can affect permissions across AWS accounts.

---

## Technologies

- AWS Identity and Access Management (IAM)
- AWS Security Token Service (STS)
- AWS Organizations
- Service Control Policies
- Terraform
- HCL
- RBAC concepts
- ABAC
- AWS resource and principal tags

---

## Repository Structure

```text
Enterprise-AWS-IAM-Architecture-with-Terraform/
├── .gitignore
├── README.md
├── Technology.md
├── Teardown.md
└── terraform/
    ├── iam/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── roles.tf
    │   ├── policies.tf
    │   ├── abac.tf
    │   └── outputs.tf
    └── org/
        └── main.tf
```

---

## Scope and Limitations

This project demonstrates selected AWS IAM and governance architecture patterns.

It does not represent:

- A complete enterprise identity platform
- A production AWS Organizations hierarchy
- A workforce federation implementation
- A complete privileged access management solution
- A complete compliance implementation
- A production-approved SCP deployment
- A validated production Terraform deployment

Additional enterprise controls such as centralized identity federation, permission boundaries, access reviews, break-glass access, CloudTrail monitoring, IAM Access Analyzer, policy testing, and CI/CD enforcement would normally be considered as part of a broader IAM architecture.

---

## Key Takeaway

AWS authorization is not a single-policy decision.

Effective IAM architecture combines multiple control layers:

```text
Identity
   |
   v
Trust Relationship
   |
   v
Role Assumption
   |
   v
Identity Permissions
   |
   v
Attribute Conditions
   |
   v
Organization Guardrails
   |
   v
AWS Resource
```

This project demonstrates how those layers can be represented through Terraform while keeping identity permissions, attribute-based authorization, and organization-level governance logically separated.
