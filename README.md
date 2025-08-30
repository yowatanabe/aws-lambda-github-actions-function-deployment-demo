# AWS Lambda GitHub Actions Function Deployment Demo

It is now possible to automatically deploy AWS Lambda functions with GitHub Actions
when code or configuration changes are pushed to a GitHub repository.

[AWS Lambda now supports GitHub Actions to simplify function deployment](https://aws.amazon.com/about-aws/whats-new/2025/08/aws-lambda-github-actions-function-deployment/)

This feature eliminates the need for cumbersome steps such as custom scripts and packaging.

This demo project is designed to try out this new capability.

## Initial Setup

1. Copy `terraform.tfvars.example` to create `terraform.tfvars`:

    ```none
    github_org  = "your-github-username"
    github_repo = "aws-lambda-github-actions-function-deployment-demo"
    ```

1. Deploy infrastructure with Terraform:

    ```bash
    cd terraform

    terraform init
    terraform plan
    terraform apply
    ```

    At this point, the Lambda function doesn't include Python packages, so executing the Lambda will result in an error.

1. Set `AWS_ROLE_TO_ASSUME` in GitHub repository Secrets:

    ```none
    AWS_ROLE_TO_ASSUME = <github_actions_deploy_role_arn from terraform output>
    ```

1. Set `AWS_REGION` in GitHub repository Variables:

    ```none
    AWS_REGION = <any region you want to use>
    ```

1. Push code to GitHub repository to trigger GitHub Actions and deploy Lambda code

## After Initial Setup

* Deployment is triggered only when files in the **src/** folder are changed
* Manual execution is possible with **workflow_dispatch**
* Changes to Terraform files and other files won't trigger unnecessary deployments
