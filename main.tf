provider "aws" {
    region = "ap-southeast-2" # Replace with your desired region
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
    name = "lambda_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = "sts:AssumeRole",
                Effect = "Allow",
                Sid    = "",
                Principal = {
                    Service = "lambda.amazonaws.com",
                },
            },
        ],
    })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
    name = "lambda_policy"
    role = aws_iam_role.lambda_role.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                ],
                Effect   = "Allow",
                Resource = "arn:aws:logs:*:*:*",
            },
            {
                Action = [
                    "sns:Publish",
                ],
                Effect   = "Allow",
                Resource = "*",
            },
        ],
    })
}

# Lambda Function
resource "aws_lambda_function" "lambda_function" {
    function_name = "my_lambda_function"
    role          = aws_iam_role.lambda_role.arn
    handler       = "index.handler"
    runtime       = "nodejs20.x" # Use the appropriate runtime for your function

    filename      = "lambda_function.zip" # Ensure you have packaged your function code

    source_code_hash = filebase64sha256("lambda_function.zip")
}

# CloudWatch Event Rule (Scheduled Event)
resource "aws_cloudwatch_event_rule" "schedule" {
    name                = "every_30_minutes"
    schedule_expression = "rate(30 minutes)"
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "target" {
    rule      = aws_cloudwatch_event_rule.schedule.name
    target_id = "lambda_target"
    arn       = aws_lambda_function.lambda_function.arn
}

# Lambda Permission for CloudWatch Events
resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_function.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

# API Gateway
resource "aws_api_gateway_rest_api" "api_gateway" {
    name        = "MyAPI"
    description = "API for my Lambda function"
}

# Resource
resource "aws_api_gateway_resource" "api_gateway_resource" {
    rest_api_id = aws_api_gateway_rest_api.api_gateway.id
    parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
    path_part   = "myresource"
}

# Method
resource "aws_api_gateway_method" "api_gateway_method" {
    rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
    resource_id   = aws_api_gateway_resource.api_gateway_resource.id
    http_method   = "GET"
    authorization = "NONE"
}

# Integration
resource "aws_api_gateway_integration" "api_gateway_integration" {
    rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
    resource_id             = aws_api_gateway_resource.api_gateway_resource.id
    http_method             = aws_api_gateway_method.api_gateway_method.http_method
    integration_http_method = "POST"
    type                    = "AWS_PROXY"
    uri                     = aws_lambda_function.lambda_function.invoke_arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "allow_api_gateway" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_function.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

# Deployment
resource "aws_api_gateway_deployment" "api_gateway_deployment" {
    depends_on = [
        aws_api_gateway_integration.api_gateway_integration,
    ]
    rest_api_id = aws_api_gateway_rest_api.api_gateway.id
    stage_name  = "prod"
}

# SNS Topic
resource "aws_sns_topic" "sns_topic" {
    name = "my_sns_topic"
}

# SNS Topic Subscription (Lambda)
resource "aws_sns_topic_subscription" "sns_lambda_subscription" {
    topic_arn = aws_sns_topic.sns_topic.arn
    protocol  = "lambda"
    endpoint  = aws_lambda_function.lambda_function.arn
}

# Lambda Permission for SNS
resource "aws_lambda_permission" "allow_sns" {
    statement_id  = "AllowExecutionFromSNS"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_function.function_name
    principal     = "sns.amazonaws.com"
    source_arn    = aws_sns_topic.sns_topic.arn
}
