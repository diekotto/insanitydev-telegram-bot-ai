variable "environment" {
  type = string
}

module "dynamodb_bot_memory" {
  source      = "./modules/dynamo_db"
  prefix      = "insanitydev"
  name        = "ai-bot-memory"
  environment = var.environment
  hash_key    = { name = "partition", type = "S" }
  range_key   = { name = "id", type = "S" }
}

# Policy for the Lambda function to access the DynamoDB table
resource "aws_iam_policy" "lambda_memory_access" {
  name        = "insanitydev-${var.environment}-ai-bot-memory-lambda-access"
  description = "Allow Lambda Bot to access DynamoDB Bot Memory"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ],
        Resource = module.dynamodb_bot_memory.arn
      }
    ]
  })
}

module "lambda_bot" {
  source      = "./modules/lambda"
  prefix      = "insanitydev"
  name        = "ai-bot"
  description = "Insanity AI Bot"
  environment = var.environment
  permissions = [
    aws_iam_policy.lambda_memory_access.arn
  ]
  handler                        = "lambda.handler"
  function_url                   = true
  reserved_concurrent_executions = 1
  timeout                        = 10
}

# module "api" {
#   source          = "./modules/api_gateway"
#   prefix          = "insanitydev"
#   name            = "ai-bot"
#   description     = "Insanity AI Bot"
#   environment     = var.environment
#   lambda_function = module.lambda_bot
# }
