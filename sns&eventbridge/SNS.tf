resource "aws_sns_topic" "Terraform_SNS" {
  name =   "Terraform_SNS-topic"
  tags = {
    name = "SNS-Terraform"
  }
}
resource "aws_sns_topic_subscription" "sns-topic-subscription" {
  topic_arn = aws_sns_topic.Terraform_SNS.arn
  protocol  = "email"
  endpoint  = "" ########## provide your email ID ########### 
  # raw_message_delivery = "true"
}
resource "aws_sns_topic_policy" "default" {
  arn                   = aws_sns_topic.Terraform_SNS.arn
  policy              = <<EOF
 {
   "Version": "2012-10-17",
   "Statement": [
    {
      "Sid": "Allows CloudWatch Events to interact with SNS topic",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": [
        "SNS:Publish",
        "SNS:Subscribe",
        "SNS:Receive"
      ],
      "Resource": "${aws_sns_topic.Terraform_SNS.arn}"
    }
  ]
 }
 EOF
}

