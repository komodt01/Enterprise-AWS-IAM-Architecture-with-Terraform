# Infrastructure Teardown Guide

## ⚠️ IMPORTANT WARNING
This teardown process will permanently delete all AWS resources created by this project. Ensure you have:
- Backed up any important data or configurations
- Confirmed this is the correct AWS account
- Obtained necessary approvals for resource deletion

## Pre-Teardown Checklist

### 1. Document Current State
```bash
# Generate final reports before teardown
make access-report
make compliance-report

# Export current Terraform state
terraform show > pre-teardown-state.txt
```

### 2. Check Dependencies
- Verify no production workloads depend on these IAM resources
- Confirm no users are actively using the roles/policies
- Check for any manual resources that reference the IAM roles

### 3. Backup Configuration
```bash
# Backup Terraform state
cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)

# Backup configuration files
tar -czf iam-config-backup-$(date +%Y%m%d_%H%M%S).tar.gz terraform/ examples/ scripts/
```

## Teardown Order (CRITICAL - Follow Sequence)

### Step 1: Remove Service Control Policies
SCPs must be detached before deleting organizational units.

```bash
cd terraform/org
terraform destroy -target=aws_organizations_policy_attachment.security_scp
terraform destroy -target=aws_organizations_policy_attachment.region_restriction_scp
```

### Step 2: Detach IAM Policies
Detach policies from roles and groups before deletion.

```bash
cd terraform/iam
terraform destroy -target=aws_iam_role_policy_attachment.engineering_abac
terraform destroy -target=aws_iam_role_policy_attachment.marketing_abac
# Repeat for all policy attachments
```

### Step 3: Destroy IAM Resources
```bash
# From project root
make destroy-iam
```

### Step 4: Remove Organization Resources
```bash
cd terraform/org
terraform destroy
```

### Step 5: Clean Up State and Remote Resources
```bash
# Remove Terraform state bucket (if using remote state)
aws s3 rb s3://iam-terraform-248839917024-komodt --force

# Clean up any remaining resources
make cleanup
```

## Automated Teardown

### Quick Teardown (Use with Caution)
```bash
# Complete infrastructure destruction
make teardown-all

# This runs:
# 1. terraform destroy -auto-approve
# 2. Removes S3 state bucket
# 3. Cleans up local state files
```

### Safe Teardown
```bash
# Interactive teardown with confirmations
make safe-teardown

# This provides step-by-step confirmations
```

## Manual Cleanup Steps

### 1. AWS Console Verification
After Terraform destroy, verify in AWS Console:
- IAM → Roles: Should show no custom roles
- IAM → Policies: Should show no custom policies  
- Organizations → SCPs: Should show no custom SCPs
- Access Analyzer: Should show no remaining analyzers

### 2. Remove Local Files
```bash
# Remove Terraform state files
rm -f terraform.tfstate*
rm -rf .terraform/

# Remove generated reports
rm -f reports/*.json
rm -f logs/*.log

# Remove backup files (if no longer needed)
rm -f *.backup.*
```

### 3. Clean Git History (Optional)
```bash
# Remove sensitive data from git history if committed
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch terraform.tfvars' \
  --prune-empty --tag-name-filter cat -- --all
```

## Troubleshooting Common Issues

### Issue: "Resource still in use"
**Problem**: IAM roles attached to EC2 instances or other resources
**Solution**: 
```bash
# Find dependencies
aws iam list-entities-for-policy --policy-arn <policy-arn>
aws iam list-role-policies --role-name <role-name>

# Remove dependencies first, then retry teardown
```

### Issue: "Access Denied"
**Problem**: Insufficient permissions to delete resources
**Solution**:
```bash
# Verify current permissions
aws sts get-caller-identity
aws iam simulate-principal-policy --policy-source-arn <user-arn> --action-names iam:DeleteRole
```

### Issue: "Organization member accounts exist"
**Problem**: Cannot delete organization with member accounts
**Solution**:
```bash
# List member accounts
aws organizations list-accounts

# Remove member accounts first (if safe to do so)
aws organizations remove-account-from-organization --account-id <account-id>
```

### Issue: Terraform state corruption
**Problem**: State file inconsistency
**Solution**:
```bash
# Import existing resources
terraform import aws_iam_role.example <role-name>

# Or refresh state
terraform refresh

# Force unlock if locked
terraform force-unlock <lock-id>
```

## Verification Steps

### Post-Teardown Verification
```bash
# Verify no custom IAM resources remain
aws iam list-roles --query 'Roles[?contains(RoleName, `Engineering`) || contains(RoleName, `Marketing`)]'
aws iam list-policies --scope Local

# Check for orphaned resources
aws iam list-role-policies --role-name <any-remaining-role>

# Verify billing impact
aws ce get-cost-and-usage --time-period Start=2023-01-01,End=2023-12-31 --granularity MONTHLY --metrics UnblendedCost
```

### Security Verification
```bash
# Ensure no backdoor access remains
aws iam get-account-authorization-details > post-teardown-iam-state.json

# Compare with baseline
diff baseline-iam-state.json post-teardown-iam-state.json
```

## Recovery Options

### Partial Recovery
If you need to restore some components:
```bash
# Restore from backup
tar -xzf iam-config-backup-<timestamp>.tar.gz

# Selective apply
terraform plan -target=aws_iam_role.engineering_role
terraform apply -target=aws_iam_role.engineering_role
```

### Full Recovery
```bash
# Restore complete infrastructure
git checkout <last-working-commit>
make init
make apply
```

## Final Notes

- Keep backup files for at least 30 days after teardown
- Document any lessons learned during teardown
- Update runbooks based on any issues encountered
- Consider setting up monitoring alerts for accidental deletions in the future

## Emergency Contacts

If teardown causes production issues:
- AWS Support: Create a support case immediately
- Internal escalation: Follow your organization's incident response procedures
- Document all actions taken for post-incident review
