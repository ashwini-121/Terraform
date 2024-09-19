resource "aws_cloudwatch_event_rule" "console" {
  name        = "capture-ec2-scaling-events"
  description = "Capture all EC2 scaling events"
  event_bus_name = "default"
  state = "ENABLED"
  event_pattern = jsonencode({
    source = [
      "aws.ec2"
    ]
    detail-type = [
      "EC2 Instance State-change Notification"
    ]
    detail = {
      "state" = [
        "Terminated",
        "Shutting-down",
        "Running",
        "Stopped"
      ]
    }
    "instance-id" = ["${aws_instance.terraform.id}"]
  })
  tags = {
    "launch" = "Terraform",
    "Target" = "Ec2" 
  }
#   schedule_expression = "cron(20 7 * * ? *)"
}
resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.Terraform_SNS.arn
}

resource "aws_iam_role" "eventbridge_role" {
  name = "eventbridge_sns_publish_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy" "eventbridge_sns_policy" {
  name        = "eventbridge_sns_publish_policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.Terraform_SNS.arn
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.eventbridge_role.name
  policy_arn = aws_iam_policy.eventbridge_sns_policy.arn
}