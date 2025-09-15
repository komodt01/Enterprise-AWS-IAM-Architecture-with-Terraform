# Enterprise AWS IAM Architecture with Terraform

A comprehensive Identity and Access Management (IAM) solution built with Terraform, implementing enterprise-grade security patterns including Role-Based Access Control (RBAC), Attribute-Based Access Control (ABAC), and AWS Organizations Service Control Policies (SCPs).

## 🏗️ Architecture Overview

This project demonstrates production-ready AWS IAM architecture with:

- **Multi-environment support** (Development, Staging, Production, Sandbox)
- **Department-based access control** (Engineering, Marketing, Finance, Operations, Security)
- **Attribute-Based Access Control (ABAC)** using resource tagging
- **Service Control Policies (SCPs)** for organizational governance
- **Modular Terraform design** for reusability and scalability
- **Compliance-ready documentation** and audit trails

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- An AWS account with Organizations enabled

### Deployment
```bash
# Clone the repository
git clone <repository-url>
cd enterprise-aws-iam-architecture

# Initialize Terraform
make init

# Plan the deployment
make plan

# Deploy infrastructure
make apply
```

## 📁 Project Structure

```
aws-iam-architecture/
├── terraform/
│   ├── org/                 # AWS Organizations and SCPs
│   ├── iam/                 # IAM roles, policies, and groups
│   ├── modules/             # Reusable Terraform modules
│   └── environments/        # Environment-specific configurations
├── examples/
│   └── abac-tagging/        # ABAC implementation examples
├── scripts/                 # Automation and testing scripts
└── docs/                    # Documentation and guides
```

## 🔐 Security Features

### Role-Based Access Control (RBAC)
- Pre-defined roles for different job functions
- Principle of least privilege implementation
- Cross-account role assumption patterns

### Attribute-Based Access Control (ABAC)
- Tag-based access control using AWS resource tags
- Dynamic permissions based on user attributes
- Fine-grained resource access controls

### Service Control Policies
- Preventive controls at the organization level
- Region restrictions and service limitations
- Compliance enforcement across all accounts

## 🛠️ Key Technologies

- **Terraform**: Infrastructure as Code
- **AWS IAM**: Identity and Access Management
- **AWS Organizations**: Multi-account governance
- **AWS Access Analyzer**: Unused access detection
- **Bash**: Automation scripting

## 📊 Compliance & Auditing

- Access Analyzer integration for unused access detection
- CloudTrail logging for audit trails
- Compliance mapping for SOC2, ISO 27001, PCI DSS
- Regular access reviews and reporting

## 🧪 Testing

```bash
# Run ABAC policy tests
make test-abac

# Generate access reports
make access-report

# Validate Terraform configurations
make validate
```



- [Technology Overview](docs/TECHNOLOGY.md)
- [Deployment Guide](docs/deployment-guide.md)
- [RBAC Design](docs/rbac-design.md)
- [ABAC Implementation](docs/abac-implementation.md)
- [Teardown Instructions](docs/TEARDOWN.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and validation
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Important Notes

- Review and update email addresses in `terraform.tfvars`
- Ensure S3 bucket names are globally unique
- Test in a development environment before production deployment
- Follow your organization's security policies and compliance requirements

## 🔍 Skills Demonstrated

**Cloud Platforms**: AWS
**Infrastructure as Code**: Terraform, HCL
**Security & Compliance**: IAM, RBAC, ABAC, SCPs, Access Analyzer
**DevOps**: Bash scripting, Automation, CI/CD integration
**Architecture**: Multi-account strategies, Enterprise patterns
