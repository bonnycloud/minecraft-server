# ------------------------------------------------------------------------------
# IAM - Policies.
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_permissions" {
  statement {
    effect = "Allow"
    resources = ["*",]
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]
  }
}

# ------------------------------------------------------------------------------
# IAM - Roles.
# ------------------------------------------------------------------------------
resource "aws_iam_role" "execution" {
  name                 = "${var.application_name}-execution"
  assume_role_policy   = data.aws_iam_policy_document.task_assume.json
}

resource "aws_iam_role_policy" "log_agent" {
  name   = "${var.application_name}-log-permissions"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.task_permissions.json
}
