resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "frontend" {
  family = "frontend"
  container_definitions = file("task-definitions/frontend.json")
  cpu = 1024
  memory = 2048
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role_cloudjoin.arn
}

resource "aws_ecs_service" "frontend" {
  launch_type = "FARGATE"
  cluster = aws_ecs_cluster.ecs_cluster.arn
  name = "frontend-svc"
  desired_count = 1
  task_definition = "${aws_ecs_task_definition.frontend.family}:${max("${aws_ecs_task_definition.frontend.revision}", "${data.aws_ecs_task_definition.frontend.revision}")}"
  network_configuration {
    security_groups = [aws_security_group.consul.id, aws_security_group.frontend_allow_group.id]
    subnets         = [module.vpc.public_subnets[0]]
    assign_public_ip = true
}
  
}

data "aws_ecs_task_definition" "frontend" {
  task_definition = aws_ecs_task_definition.frontend.family
  depends_on = [aws_ecs_task_definition.frontend]
}


resource "aws_ecs_task_definition" "checkout" {
  family = "checkout"
  container_definitions = file("task-definitions/checkout.json")
  cpu = 1024
  memory = 2048
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role_cloudjoin.arn
}

resource "aws_ecs_service" "checkout" {
  launch_type = "FARGATE"
  cluster = aws_ecs_cluster.ecs_cluster.arn
  name = "checkout-svc"
  desired_count = 3
  task_definition = "${aws_ecs_task_definition.checkout.family}:${max("${aws_ecs_task_definition.checkout.revision}", "${data.aws_ecs_task_definition.checkout.revision}")}"
  network_configuration {
    security_groups = [aws_security_group.consul.id]
    subnets         = [module.vpc.public_subnets[0]]
    assign_public_ip = true
}
}

data "aws_ecs_task_definition" "checkout" {
  task_definition = aws_ecs_task_definition.checkout.family
  depends_on = [aws_ecs_task_definition.checkout]
}

resource "aws_ecs_task_definition" "payments" {
  family = "payments"
  container_definitions = file("task-definitions/payments.json")
  cpu = 1024
  memory = 2048
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role_cloudjoin.arn
}

resource "aws_ecs_service" "payments" {
  launch_type = "FARGATE"
  cluster = aws_ecs_cluster.ecs_cluster.arn
  name = "payments-svc"
  desired_count = 3
  task_definition = "${aws_ecs_task_definition.payments.family}:${max("${aws_ecs_task_definition.payments.revision}", "${data.aws_ecs_task_definition.payments.revision}")}"
  network_configuration {
    security_groups = [aws_security_group.consul.id]
    subnets         = [module.vpc.public_subnets[0]]
    assign_public_ip = true
}
}

data "aws_ecs_task_definition" "payments" {
  task_definition = aws_ecs_task_definition.payments.family
  depends_on = [aws_ecs_task_definition.payments]
}


resource "aws_ecs_task_definition" "ingress" {
  family = "ingress"
  container_definitions = file("task-definitions/ingress.json")
  cpu = 1024
  memory = 2048
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role_cloudjoin.arn
}

resource "aws_ecs_service" "ingress" {
  launch_type = "FARGATE"
  cluster = aws_ecs_cluster.ecs_cluster.arn
  name = "ingress-svc"
  desired_count = 2
  task_definition = "${aws_ecs_task_definition.ingress.family}:${max("${aws_ecs_task_definition.ingress.revision}", "${data.aws_ecs_task_definition.ingress.revision}")}"
  network_configuration {
    security_groups = [aws_security_group.consul.id]
    subnets         = [module.vpc.public_subnets[0]]
    assign_public_ip = true
}
}

data "aws_ecs_task_definition" "ingress" {
  task_definition = aws_ecs_task_definition.ingress.family
  depends_on = [aws_ecs_task_definition.ingress]
}