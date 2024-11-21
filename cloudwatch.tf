resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name = "${var.project_name}-cloudwatch-logs-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          # CloudWatch logs and metrics
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "cloudwatch:PutMetricData",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:PutDashboard",
          "cloudwatch:GetDashboard",
          "cloudwatch:DeleteDashboards",
          "cloudwatch:ListDashboards",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          # Parameter Store
          "ssm:GetParameter",
          "ssm:PutParameter",
          "ssm:DescribeParameters",
          # SSM permissions
          "ssm:SendCommand",
          "ssm:ListCommands",
          "ssm:GetCommandInvocation",
          "ssm:StartSession",
          "ssm:DescribeInstanceInformation",
          "ec2messages:*"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "cloudwatch_logs_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_cloudwatch_log_group" "java_logs" {
  name              = "/aws/java/application-logs"
  retention_in_days = 1 
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_dashboard" "java_dashboard" {
  dashboard_name = "JavaMonitoringDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            ["CustomNamespace", "JavaAppRequests", { "label": "Requests Processed" }]
          ],
          "period": 300,
          "stat": "Sum",
          "region": "us-east-1",
          "title": "Java Application Requests"
        }
      },
      {
        "type": "metric",
        "x": 12,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "*"]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "CPU Utilization"
        }
      }
    ]
  })
}

data "template_file" "cloudwatch_config" {
  template = file("${path.module}/cloudwatch-config.json.tpl")
}

resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  name        = "/AmazonCloudWatch/java-logs-config"
  type        = "String"
  description = "Configuration file for CloudWatch Agent"
  value       = data.template_file.cloudwatch_config.rendered
}

#possibilité de rajouter une alarme cloudwatch avec un topic sns 