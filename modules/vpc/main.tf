terraform {
    required_version = ">= 1.2.3"
}

#data "aws_availability_zones" "available" {
#  state = "available"
# }

# Define vpc
resource "aws_vpc" "vpc-net" {
    cidr_block           = var.cidr_block
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags = {
        Name = "${var.vpc_name}-network"
    }
}



# Define the private subnet
resource "aws_subnet" "private-subnet" {
    count                   = "${length(var.private_subnet_cidr)}"
    vpc_id                  = "${aws_vpc.vpc-net.id}"
    cidr_block              = "${var.private_subnet_cidr[count.index]}"
    availability_zone       = "${var.availability_zones[count.index]}"
    
    map_public_ip_on_launch = false

    tags = {
      Name = "private-subnet-${var.availability_zones[count.index]}"
    }
}

# Define the public subnet
resource "aws_subnet" "public-subnet" {
    count                   = "${length(var.public_subnet_cidr)}"
    #az_count                = "${length(var.availability_zones)}"
    vpc_id                  = "${aws_vpc.vpc-net.id}"
    cidr_block              = "${var.public_subnet_cidr[count.index]}"
    availability_zone       = "${var.availability_zones[count.index]}"
    #availability_zone       = "${var.availability_zones.*}"

    map_public_ip_on_launch = true

    tags = {
      Name = "public-subnet-${var.availability_zones[count.index]}"
    }
}


resource "aws_default_route_table" "public" {
  default_route_table_id = "${aws_vpc.vpc-net.main_route_table_id}"

  tags = {
    Name = "rt-public"
  }
}

resource "aws_internet_gateway" "ig_public" {
    vpc_id = "${aws_vpc.vpc-net.id}"

    tags = {
      Name = "default-ig-public"
    }
}

resource "aws_route" "public_rt" {
  count                  = "${length(var.public_subnet_cidr)}"
  route_table_id         = "${aws_default_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig_public.id}"

  timeouts {
    create = "5m"
  }
}


resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  route_table_id = "${aws_default_route_table.public.id}"
}


resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc-net.id}"

  tags = {
    Name = "rt-private"
  }
}


resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.private-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.vpc-net.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "private-nat-gw-eip"
  }
}


resource "aws_nat_gateway" "nat-gt-private" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public-subnet.0.id}"

  tags = {
    Name = "private-nat-gw"
  }
}


resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat-gt-private.id}"

  timeouts {
    create = "5m"
  }
}