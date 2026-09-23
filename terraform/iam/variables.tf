variable "aws_region" {
  description = "AWS region used for regional resources in the architecture"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment associated with the IAM architecture"
  type        = string
  default     = "development"

  validation {
    condition = contains(
      ["development", "staging", "production"],
      var.environment
    )

    error_message = "Environment must be development, staging, or production."
  }
}

variable "department" {
  description = "Department attribute used to demonstrate tag-based access control"
  type        = string
  default     = "engineering"
}
