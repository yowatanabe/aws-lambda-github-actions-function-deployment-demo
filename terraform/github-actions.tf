# GitHub OIDC provider
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # thumbprint_list is no longer required for GitHub Actions OIDC as of 2023
  # Ignoring changes to avoid Terraform drift when AWS manages this automatically
  # Reference: https://github.com/aws-actions/configure-aws-credentials?tab=readme-ov-file#configuring-iam-to-trust-github
  lifecycle {
    ignore_changes = [
      thumbprint_list
    ]
  }
}

# GitHub Actions deployment role
resource "aws_iam_role" "gha_deploy" {
  name               = "${var.function_name}-gha-deploy"
  assume_role_policy = data.aws_iam_policy_document.gha_assume.json
}

# https://github.com/aws-actions/aws-lambda-deploy?tab=readme-ov-file#openid-connect-oidc
data "aws_iam_policy_document" "gha_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:*"]
    }
  }
}

# GitHub Actions deployment policy
resource "aws_iam_policy" "gha_deploy" {
  name   = "${var.function_name}-gha-deploy"
  policy = data.aws_iam_policy_document.gha_policy.json
}

# https://github.com/aws-actions/aws-lambda-deploy?tab=readme-ov-file#permissions
data "aws_iam_policy_document" "gha_policy" {
  statement {
    sid    = "LambdaDeployPermissions"
    effect = "Allow"
    actions = [
      "lambda:GetFunctionConfiguration",
      "lambda:CreateFunction",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "lambda:PublishVersion",
    ]
    resources = [
      "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${var.function_name}",
    ]
  }

  statement {
    sid    = "PassRolePermission"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.lambda_exec.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "gha_deploy_attach" {
  role       = aws_iam_role.gha_deploy.name
  policy_arn = aws_iam_policy.gha_deploy.arn
}
