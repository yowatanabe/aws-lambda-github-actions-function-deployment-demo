variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "ap-northeast-1"
}

variable "function_name" {
  type        = string
  description = "Lambda function name"
  default     = "sample-gha-lambda"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.13"
}

# GitHub OIDC target (owner/repo)
variable "github_org" {
  type        = string
  description = "GitHub org/user (e.g. your-org)"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo name (e.g. your-repo)"
}
