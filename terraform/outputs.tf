output "lambda_function_name" {
  value = aws_lambda_function.this.function_name
}

output "github_actions_deploy_role_arn" {
  value = aws_iam_role.gha_deploy.arn
}

output "lambda_exec_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}
