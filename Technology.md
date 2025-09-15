# Technology Overview

## What is AWS Identity and Access Management (IAM)?

AWS Identity and Access Management (IAM) is a web service that helps you securely control access to AWS resources. IAM enables you to manage users, groups, roles, and permissions to determine who can access which AWS services and resources under what conditions.

## Core Components

### 1. AWS Organizations
**Purpose**: Centrally manage multiple AWS accounts
**How it works**: 
- Creates a hierarchical structure of organizational units (OUs)
- Applies Service Control Policies (SCPs) to restrict actions across accounts
- Enables centralized billing and management

### 2. Service Control Policies (SCPs)
**Purpose**: Set maximum permissions boundaries across AWS accounts
**How it works**:
- JSON documents that define allowed/denied actions
- Applied at the organization, OU, or account level
- Act as guardrails preventing unauthorized actions
- Cannot grant permissions, only restrict them

### 3. IAM Roles
**Purpose**: Provide temporary, assumable identities for AWS resources and users
**How it works**:
- Define a set of permissions without being tied to a specific user
- Can be assumed by EC2 instances, Lambda functions, or users
- Include trust policies that specify who can assume the role
- Support cross-account access patterns

### 4. IAM Policies
**Purpose**: Define permissions in JSON format
**Types**:
- **Identity-based policies**: Attached to users, groups, or roles
- **Resource-based policies**: Attached directly to resources
- **Permission boundaries**: Set maximum permissions
- **Session policies**: Limit permissions during role assumption

### 5. Role-Based Access Control (RBAC)
**Purpose**: Assign permissions based on job functions
**How it works**:
- Users are assigned to roles based on their job responsibilities
- Roles contain predefined sets of permissions
- Simplifies permission management at scale
- Follows principle of least privilege

### 6. Attribute-Based Access Control (ABAC)
**Purpose**: Dynamic access control based on attributes
**How it works**:
- Uses resource tags, user attributes, and environmental conditions
- Policies evaluate attributes at runtime to make access decisions
- Provides fine-grained, contextual access control
- Reduces the need for multiple static policies

## How This Architecture Works

### 1. Organizational Structure
```
Root Organization
├── Security OU
├── Development OU
├── Production OU
└── Sandbox OU
```

### 2. Permission Flow
1. **User Request**: User attempts to access AWS resource
2. **Role Assumption**: User assumes role based on department/function
3. **Policy Evaluation**: AWS evaluates all applicable policies
4. **ABAC Check**: System checks resource tags and user attributes
5. **SCP Verification**: Organization policies are enforced
6. **Access Decision**: Allow/deny based on combined evaluation

### 3. Tag-Based Access (ABAC Example)
```json
{
  "Effect": "Allow",
  "Action": "ec2:*",
  "Resource": "*",
  "Condition": {
    "StringEquals": {
      "ec2:ResourceTag/Department": "${aws:PrincipalTag/Department}",
      "ec2:ResourceTag/Environment": "${aws:PrincipalTag/Environment}"
    }
  }
}
```

## Infrastructure as Code with Terraform

### Why Terraform?
- **Declarative**: Define desired end state
- **Version Control**: Track infrastructure changes
- **Modularity**: Reusable components
- **State Management**: Track resource dependencies
- **Provider Ecosystem**: Extensive AWS support

### Module Structure
- **iam-role**: Creates roles with trust policies and permissions
- **policy**: Manages custom IAM policies
- **scp**: Handles Service Control Policies
- **Environment-specific**: Customizes deployments per environment

## Security Benefits

### Defense in Depth
1. **SCPs**: Organization-level restrictions
2. **IAM Policies**: User/role-level permissions
3. **Resource Policies**: Resource-level access control
4. **ABAC**: Context-aware access decisions

### Compliance Alignment
- **SOC 2**: Access control and monitoring
- **ISO 27001**: Information security management
- **PCI DSS**: Secure access to cardholder data
- **GDPR**: Data protection and access controls

### Audit and Monitoring
- **AWS CloudTrail**: API call logging
- **Access Analyzer**: Unused access detection
- **Config Rules**: Compliance monitoring
- **Automated Reporting**: Regular access reviews

## Scalability Features

### Multi-Account Strategy
- Isolates workloads and environments
- Provides natural permission boundaries
- Enables independent billing and governance
- Supports different compliance requirements per account

### Automation Integration
- CI/CD pipeline integration
- Automated policy testing
- Infrastructure drift detection
- Self-service provisioning capabilities

## Best Practices Implemented

1. **Principle of Least Privilege**: Minimal necessary permissions
2. **Separation of Duties**: Role-based access separation
3. **Regular Access Reviews**: Automated reporting and analysis
4. **Centralized Management**: Single source of truth for permissions
5. **Immutable Infrastructure**: Version-controlled, reproducible deployments
