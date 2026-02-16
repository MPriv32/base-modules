#############################################
# VPC
#############################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true   # Required for internal DNS resolution
  enable_dns_hostnames = true   # Required for service discovery & ECS/EKS

  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}


#############################################
# Public Subnet
#############################################

resource "aws_subnet" "public" {
  for_each = toset(var.azs)

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, index(var.azs, each.key))
  map_public_ip_on_launch = true  # Public-facing resources need public IP

  tags = merge(var.tags, {
    Name = "${var.name}-public-${each.key}"
  })
}

#############################################
# Private Subnet
#############################################

resource "aws_subnet" "private" {
  for_each = toset(var.azs)

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(var.azs, each.key) + 10)

  tags = merge(var.tags, {
    Name = "${var.name}-private-${each.key}"
  })
}

#############################################
# Internet Gateway
#############################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}


#############################################
# Public Route Table
#############################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

#############################################
# EIP, NAT Gateway, and Private Route Table (Conditional on NAT)
#############################################

resource "aws_eip" "nat" {
  count  = var.enable_nat ? 1 : 0
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat ? 1 : 0
  subnet_id     = values(aws_subnet.public)[0].id
  allocation_id = aws_eip.nat[0].id

  tags = merge(var.tags, {
    Name = "${var.name}-nat"
  })
}

resource "aws_route" "private_nat" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

#############################################
# Private Route Table
#############################################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-private-rt"
  })
}

#############################################
# Explicit Route Table Associations
#############################################

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

#############################################
# Default Security Group Hardening
#############################################

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id

  # Remove all inbound rules by default
  # Prevents accidental overly-permissive access
  ingress = []

  # Allow all outbound (stateful SG)
  # In production you may restrict further
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-default-sg"
  })
}

#############################################
# S3 Gateway VPC Endpoint (Free)
#############################################

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  # Attach endpoint to private route table
  # Allows private subnet access to S3 without NAT
  route_table_ids = [aws_route_table.private.id]

  tags = merge(var.tags, {
    Name = "${var.name}-s3-endpoint"
  })
}

# Create ECR API endpoints
resource "aws_vpc_endpoint" "ecr_api" {
  count             = var.create_ecr_endpoints ? 1 : 0
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for s in values(aws_subnet.private) : s.id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name      = "${var.name}-ecr-api-endpoint"
    ManagedBy = "Terraform"
  })
}

# Create ECR DKR endpoints
resource "aws_vpc_endpoint" "ecr_dkr" {
  count             = var.create_ecr_endpoints ? 1 : 0
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [for s in values(aws_subnet.private) : s.id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name      = "${var.name}-ecr-dkr-endpoint"
    ManagedBy = "Terraform"
  })
}

#############################################
# SSM Endpoints (API + Messages)
#############################################
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [for s in values(aws_subnet.private) : s.id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name      = "${var.name}-ssm-endpoint"
    ManagedBy = "Terraform"
  })
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [for s in values(aws_subnet.private) : s.id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name      = "${var.name}-ssmmessages-endpoint"
    ManagedBy = "Terraform"
  })
}

#############################################
# CloudWatch Logs Endpoint
#############################################
resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [for s in values(aws_subnet.private) : s.id]
  security_group_ids = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name      = "${var.name}-logs-endpoint"
    ManagedBy = "Terraform"
  })
}

#############################################
# Interface Security Group for Endpoints
#############################################
resource "aws_security_group" "endpoint_sg" {
  name        = "${var.name}-endpoint-sg"
  vpc_id      = aws_vpc.this.id
  description = "Security group for interface endpoints (ECR / SSM)"

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { ManagedBy = "Terraform" })
}

#############################################
# Optional VPC Flow Logs
#############################################

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${var.name}-flow-logs"
  retention_in_days = 7
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id         = aws_vpc.this.id
  traffic_type   = "ALL"
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
}