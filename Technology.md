# Technology Overview

## Purpose

This document describes the technologies and security concepts implemented in the Enterprise AWS IAM Architecture with Terraform project.

The implementation focuses on AWS IAM authorization, attribute-based access control, AWS Organizations guardrails, and Infrastructure as Code.

---

## AWS Identity and Access Management

AWS Identity and Access Management (IAM) provides the authorization controls used to determine which AWS principals can perform actions against AWS resources.

This project demonstrates several IAM concepts:

- IAM roles
- Role trust policies
- Identity-based policies
- Least-privilege permissions
- Principal tags
- Resource tags
- Attribute-Based Access Control (ABAC)

---

## IAM Roles

The architecture uses an IAM role rather than creating long-lived IAM users.

The implemented role follows the naming pattern:

```text
SecurityArchitect-<environment>
```

For example:

```text
SecurityArchitect-development
```

The role provides the identity boundary around which trust, permissions, and attributes are applied.

---

## Trust Policies

An IAM role has a trust policy that determines which principals are trusted to request role assumption.

The project defines the trust relationship separately from the permissions granted to the role.

Conceptually:

```text
Trust Policy
     |
     +-- Who can assume the role?

Permissions Policy
     |
     +-- What can the role do?
```

Keeping these concerns separate makes the authorization model easier to understand and review.

---

## AWS Security Token Service

AWS Security Token Service (STS) supports temporary AWS security credentials and role assumption.

The trust policy permits:

```text
sts:AssumeRole
```

Role-based access provides a foundation for temporary credentials rather than designing access around permanent IAM user credentials.

The project does not implement a complete workforce federation solution. In an enterprise environment, role assumption could be integrated with an external identity provider or centralized workforce identity service.

---

## Least-Privilege IAM Policy

The Security Architect role receives a custom policy providing selected read access to IAM configuration.

Implemented actions include:

```text
iam:GetRole
iam:GetPolicy
iam:GetPolicyVersion
iam:ListRoles
iam:ListPolicies
sts:GetCallerIdentity
```

The project intentionally avoids broad administrative permissions such as:

```text
AdministratorAccess
iam:*
```

This demonstrates the architectural principle of granting permissions required for the intended function rather than broad account-level authority.

---

## Attribute-Based Access Control

Attribute-Based Access Control uses attributes associated with identities, resources, or request context when making authorization decisions.

The project demonstrates ABAC using:

```text
Department
Environment
```

The IAM role receives these tags:

```text
Department  = <department>
Environment = <environment>
```

The EC2 authorization policy then compares those principal attributes with resource tags.

---

## ABAC Authorization Flow

The implemented model is:

```text
Principal
   |
   +-- Department = engineering
   +-- Environment = development
             |
             v
       IAM Policy Evaluation
             |
             v
Compare Principal Attributes
with EC2 Resource Attributes
             |
       +-----+-----+
       |           |
     Match       No Match
       |           |
       v           v
    Allowed     Not Allowed
```

The policy uses:

```text
aws:PrincipalTag/Department
aws:PrincipalTag/Environment
```

and compares them with:

```text
ec2:ResourceTag/Department
ec2:ResourceTag/Environment
```

---

## EC2 Authorization Example

The ABAC example permits:

```text
ec2:StartInstances
ec2:StopInstances
```

for EC2 instances whose Department and Environment tags match the corresponding principal tags.

The project handles:

```text
ec2:DescribeInstances
```

separately with `Resource = "*"`, reflecting the authorization characteristics of that API action.

This demonstrates why IAM policies must be designed around the capabilities of individual AWS actions rather than assuming every action supports identical resource-level restrictions.

---

## AWS Organizations

AWS Organizations provides centralized governance across multiple AWS accounts.

This project uses Organizations as the architectural boundary for demonstrating a Service Control Policy.

IAM policies and SCPs serve different purposes:

```text
IAM Policy
     |
     +-- Grants or limits permissions for identities

SCP
     |
     +-- Establishes the maximum available permission boundary
         for affected organization accounts
```

An SCP does not independently grant permissions.

---

## Service Control Policy

The project defines an example regional SCP.

Its objective is to deny applicable actions outside the approved regions:

```text
us-east-1
us-west-2
```

Selected global AWS services are excluded from the regional restriction.

The Terraform configuration creates the policy definition but does not attach the SCP to an organizational unit or account.

This intentionally separates:

```text
Policy Definition
       |
       v
Security Review
       |
       v
Approval
       |
       v
Organizational Enforcement
```

That separation is particularly important for preventive controls that can affect multiple AWS accounts.

---

## Terraform

Terraform provides the Infrastructure as Code implementation for the architecture.

The project uses Terraform to represent:

- AWS provider configuration
- Input variables
- IAM role
- IAM trust policy
- IAM permissions policy
- ABAC policy
- Policy attachments
- Resource attributes
- Terraform outputs
- AWS Organizations SCP

The configuration is separated into IAM and organization governance components:

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

---

## Terraform Variables

The IAM configuration accepts variables for:

```text
aws_region
environment
department
```

Supported environments are:

```text
development
staging
production
```

Terraform validation prevents unsupported environment values from being accepted by the configuration.

This demonstrates how Infrastructure as Code can encode architecture constraints rather than relying entirely on documentation.

---

## Terraform Outputs

The implementation exposes outputs for:

```text
Security Architect role name
Security Architect role ARN
Read-only policy ARN
ABAC policy ARN
```

Outputs make created resources easier to identify and provide useful evidence when validating a Terraform deployment.

---

## Terraform State Security

Terraform state can contain infrastructure metadata and potentially sensitive information.

The repository therefore excludes local state and variable files using `.gitignore`.

Examples include:

```text
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
.terraform/
```

A production architecture should use a secured remote state design with appropriate encryption, access control, locking, backup, and recovery mechanisms.

Remote state is not implemented by this project.

---

## Control Layers

The architecture demonstrates multiple authorization layers:

```text
Identity Context
      |
      v
Role Trust Policy
      |
      v
Role Assumption
      |
      v
IAM Permissions
      |
      v
ABAC Conditions
      |
      v
Organization SCP
      |
      v
AWS Resource
```

Each layer addresses a different security question.

**Trust:** Who may assume the identity?

**Permissions:** What actions may the identity perform?

**Attributes:** Under what contextual conditions may those actions occur?

**Organization guardrails:** Which permissions should remain unavailable regardless of account-level IAM configuration?

---

## Implemented Technologies

The current repository contains implementation evidence for:

- AWS IAM
- AWS STS role assumption concepts
- IAM trust policies
- IAM identity-based policies
- AWS principal tags
- AWS resource tags
- ABAC
- AWS Organizations
- Service Control Policies
- Terraform
- HCL

---

## Production Considerations

A broader enterprise IAM architecture could also include:

- Workforce identity federation
- AWS IAM Identity Center
- Permission boundaries
- Privileged access controls
- Break-glass access
- IAM Access Analyzer
- CloudTrail monitoring
- Centralized security logging
- Automated access reviews
- Policy testing
- CI/CD validation
- Remote Terraform state
- Terraform state locking
- Organizational unit design
- SCP deployment workflows
- Exception governance

These capabilities are architectural considerations and are **not represented as implemented controls in this repository**.

---

## Current Validation Status

The Terraform source demonstrates the intended IAM and organization governance architecture.

The project does not currently claim successful deployment or AWS runtime validation.

Before deployment, the configurations should be evaluated using:

```bash
terraform fmt
terraform init
terraform validate
terraform plan
```

Organization-level policies should also receive security and operational review before attachment to an AWS Organizations target.
