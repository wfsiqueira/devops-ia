data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(
    data.aws_availability_zones.available.names,
    0,
    min(var.availability_zone_count, length(data.aws_availability_zones.available.names)),
  )

  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project
  }

  public_subnet_cidrs = {
    for index, availability_zone in local.availability_zones :
    availability_zone => cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, index)
  }

  private_subnet_cidrs = {
    for index, availability_zone in local.availability_zones :
    availability_zone => cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, index + length(local.availability_zones))
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "vpc-${var.environment}-${var.project}-main"
  })

  lifecycle {
    precondition {
      condition = (
        length(local.availability_zones) >= 2 &&
        (length(var.availability_zones) > 0 || length(local.availability_zones) == var.availability_zone_count) &&
        pow(2, var.subnet_newbits) >= 2 * length(local.availability_zones) &&
        tonumber(split("/", var.vpc_cidr_block)[1]) + var.subnet_newbits <= 28
      )
      error_message = "Use at least two available AZs, enough subnet_newbits for two subnets per AZ, and subnet CIDRs no smaller than /28."
    }
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "internet-gateway-${var.environment}-${var.project}-main"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnet_cidrs

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "subnet-${var.environment}-${var.project}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private_subnet_cidrs

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(local.common_tags, {
    Name = "subnet-${var.environment}-${var.project}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "route-table-${var.environment}-${var.project}-public"
    Tier = "public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "elastic-ip-${var.environment}-${var.project}-nat-${each.key}"
  })
}

resource "aws_nat_gateway" "this" {
  for_each = aws_subnet.public

  allocation_id     = aws_eip.nat[each.key].id
  connectivity_type = "public"
  subnet_id         = each.value.id

  depends_on = [aws_internet_gateway.this]

  tags = merge(local.common_tags, {
    Name = "nat-gateway-${var.environment}-${var.project}-${each.key}"
  })
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "route-table-${var.environment}-${var.project}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_route" "private_internet" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
