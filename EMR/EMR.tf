resource "aws_emr_cluster" "cluster" {
  name          = "Terraform-emr"
  release_label = "${var.release_label}"
  applications  = ["Spark", "Hadoop", "zeppelin"]
  master_instance_group {
    instance_type = var.instance_type
    instance_count = 1
    name = "Master"
    # bid_price = "OnDemandPrice"
  }
  core_instance_group {
    instance_count = 1
    instance_type  = var.instance_type
    name = "Core"
    # bid_price = "OnDemandPrice"
  }
  ebs_root_volume_size = 10
  visible_to_all_users = "true"
  # log_uri = "s3://terraformemrs3logbucket"
  service_role = "arn:aws:iam::905418457282:role/service-role/AmazonEMR-ServiceRole-20240809T045049"
  termination_protection = "false"
  # bootstrap_action {
  #   path = "s3://terraformemrs3logbucket/bootstrapfile1.sh"
  #   args =  []
  #   name = "bootstrapAction"
  # }
  ec2_attributes {
    subnet_id                         = "subnet-0d904582a0b6d31ba"
    emr_managed_master_security_group = "sg-09a45395056618d08"
    emr_managed_slave_security_group  = "sg-09a45395056618d08"
    instance_profile                  = "arn:aws:iam::905418457282:instance-profile/AmazonEMR-InstanceProfile-20240809T045032"
    key_name = "${var.ami_key_pair_name}"
  }
  tags = {
    env      = "env"
    name     = "name-env"
  }
########### custom scaling ##########################
  #  autoscaling_policy = jsonencode({
  #   Constraints = {
  #     MinCapacity = 1
  #     MaxCapacity = 3
  #   }
  #   Rules = [
  #     {
  #       Name = "ScaleOut"
  #       Description = "Scale out rule"
  #       Action = {
  #         SimpleScalingPolicyConfiguration = {
  #           AdjustmentType = "CHANGE_IN_CAPACITY"
  #           ScalingAdjustment = 1
  #           CoolDown = 300
  #         }
  #       }
  #       Trigger = {
  #         CloudWatchAlarmDefinition = {
  #           ComparisonOperator = "GREATER_THAN_OR_EQUAL"
  #           EvaluationPeriods = 1
  #           MetricName = "YARNMemoryAvailablePercentage"
  #           Namespace = "AWS/ElasticMapReduce"
  #           Period = 300
  #           Statistic = "AVERAGE"
  #           Threshold = 75.0
  #         }
  #       }
  #     },
  #     {
  #       Name = "ScaleIn"
  #       Description = "Scale in rule"
  #       Action = {
  #         SimpleScalingPolicyConfiguration = {
  #           AdjustmentType = "CHANGE_IN_CAPACITY"
  #           ScalingAdjustment = -1
  #           CoolDown = 300
  #         }
  #       }
  #       Trigger = {
  #         CloudWatchAlarmDefinition = {
  #           ComparisonOperator = "LESS_THAN_OR_EQUAL"
  #           EvaluationPeriods = 1
  #           MetricName = "YARNMemoryAvailablePercentage"
  #           Namespace = "AWS/ElasticMapReduce"
  #           Period = 300
  #           Statistic = "AVERAGE"
  #           Threshold = 25.0
  #         }
  #       }
  #     }
  #   ]
  # })
}
# Managed Scaling Policy
resource "aws_emr_managed_scaling_policy" "samplepolicy" {
  cluster_id = aws_emr_cluster.cluster.id
  compute_limits {
    unit_type                       = "Instances"
    minimum_capacity_units          = 1
    maximum_capacity_units          = 10
    maximum_ondemand_capacity_units = 10
    maximum_core_capacity_units     = 1
  }
}
### task instance group
resource "aws_emr_instance_group" "task_group" {
  cluster_id    = aws_emr_cluster.cluster.id
  instance_type = "m1.medium"
  instance_count = 1
}

output "emr_cluster_id" {
  value = aws_emr_cluster.cluster.id
}

output "emr_master_public_dns" {
  value = aws_emr_cluster.cluster.master_public_dns
}

# IAM Role setups

# # IAM role for EMR Service
# data "aws_iam_policy_document" "emr_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["elasticmapreduce.amazonaws.com"]
#     }

#     actions = "sts:AssumeRole"
#   }
# }

# resource "aws_iam_role" "iam_emr_service_role" {
#   name               = "iam_emr_service_role"
#   assume_role_policy = data.aws_iam_policy_document.emr_assume_role.json
# }

# data "aws_iam_policy_document" "iam_emr_service_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "ec2:AuthorizeSecurityGroupEgress",
#       "ec2:AuthorizeSecurityGroupIngress",
#       "ec2:CancelSpotInstanceRequests",
#       "ec2:CreateNetworkInterface",
#       "ec2:CreateSecurityGroup",
#       "ec2:CreateTags",
#       "ec2:DeleteNetworkInterface",
#       "ec2:DeleteSecurityGroup",
#       "ec2:DeleteTags",
#       "ec2:DescribeAvailabilityZones",
#       "ec2:DescribeAccountAttributes",
#       "ec2:DescribeDhcpOptions",
#       "ec2:DescribeInstanceStatus",
#       "ec2:DescribeInstances",
#       "ec2:DescribeKeyPairs",
#       "ec2:DescribeNetworkAcls",
#       "ec2:DescribeNetworkInterfaces",
#       "ec2:DescribePrefixLists",
#       "ec2:DescribeRouteTables",
#       "ec2:DescribeSecurityGroups",
#       "ec2:DescribeSpotInstanceRequests",
#       "ec2:DescribeSpotPriceHistory",
#       "ec2:DescribeSubnets",
#       "ec2:DescribeVpcAttribute",
#       "ec2:DescribeVpcEndpoints",
#       "ec2:DescribeVpcEndpointServices",
#       "ec2:DescribeVpcs",
#       "ec2:DetachNetworkInterface",
#       "ec2:ModifyImageAttribute",
#       "ec2:ModifyInstanceAttribute",
#       "ec2:RequestSpotInstances",
#       "ec2:RevokeSecurityGroupEgress",
#       "ec2:RunInstances",
#       "ec2:TerminateInstances",
#       "ec2:DeleteVolume",
#       "ec2:DescribeVolumeStatus",
#       "ec2:DescribeVolumes",
#       "ec2:DetachVolume",
#       "iam:GetRole",
#       "iam:GetRolePolicy",
#       "iam:ListInstanceProfiles",
#       "iam:ListRolePolicies",
#       "iam:PassRole",
#       "s3:CreateBucket",
#       "s3:Get*",
#       "s3:List*",
#       "sdb:BatchPutAttributes",
#       "sdb:Select",
#       "sqs:CreateQueue",
#       "sqs:Delete*",
#       "sqs:GetQueue*",
#       "sqs:PurgeQueue",
#       "sqs:ReceiveMessage",
#     ]

#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy" "iam_emr_service_policy" {
#   name   = "iam_emr_service_policy"
#   role   = aws_iam_role.iam_emr_service_role.id
#   policy = data.aws_iam_policy_document.iam_emr_service_policy.json
# }

# # IAM Role for EC2 Instance Profile
# data "aws_iam_policy_document" "ec2_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }

#     actions = "sts:AssumeRole"
#   }
# }

# resource "aws_iam_role" "iam_emr_profile_role" {
#   name               = "iam_emr_profile_role"
#   assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
# }

# resource "aws_iam_instance_profile" "emr_profile" {
#   name = "emr_profile"
#   role = aws_iam_role.iam_emr_profile_role.name
# }

# data "aws_iam_policy_document" "iam_emr_profile_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "cloudwatch:*",
#       "dynamodb:*",
#       "ec2:Describe*",
#       "elasticmapreduce:Describe*",
#       "elasticmapreduce:ListBootstrapActions",
#       "elasticmapreduce:ListClusters",
#       "elasticmapreduce:ListInstanceGroups",
#       "elasticmapreduce:ListInstances",
#       "elasticmapreduce:ListSteps",
#       "kinesis:CreateStream",
#       "kinesis:DeleteStream",
#       "kinesis:DescribeStream",
#       "kinesis:GetRecords",
#       "kinesis:GetShardIterator",
#       "kinesis:MergeShards",
#       "kinesis:PutRecord",
#       "kinesis:SplitShard",
#       "rds:Describe*",
#       "s3:*",
#       "sdb:*",
#       "sns:*",
#       "sqs:*",
#     ]

#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy" "iam_emr_profile_policy" {
#   name   = "iam_emr_profile_policy"
#   role   = aws_iam_role.iam_emr_profile_role.id
#   policy = data.aws_iam_policy_document.iam_emr_profile_policy.json
# }