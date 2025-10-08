# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/eks/${var.project_name}-${var.environment}"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-${var.environment}-log-group"
  }
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-${var.environment}-alarms"

  tags = {
    Name = "${var.project_name}-${var.environment}-alarms"
  }
}

resource "aws_sns_topic_subscription" "alarms_email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EKS", "cluster_failed_node_count", "ClusterName", var.eks_cluster_name, { stat = "Average", label = "Failed Nodes" }],
            [".", "cluster_node_count", ".", ".", { stat = "Average", label = "Total Nodes" }]
          ]
          period = 300
          region = data.aws_region.current.name
          title  = "EKS Cluster Metrics"
          stat   = "Average"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Logs", "IncomingLogEvents", "LogGroupName", aws_cloudwatch_log_group.main.name, { stat = "Sum", label = "Log Events" }]
          ]
          period = 300
          region = data.aws_region.current.name
          title  = "Application Logs"
          stat   = "Sum"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      }
    ]
  })
}

# Data source to get current AWS region
data "aws_region" "current" {}
