resource "aws_ecr_repository" "budget" {
  name = "${var.stack_identifier}-budget"
}