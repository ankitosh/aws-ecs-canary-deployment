## VPC ###

resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags = {
    Name = "${var.customer}-VPC-${var.appname}-${var.envr}"
  }
}

# Public Subnet

resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.public_subnet_cidr, count.index)}"
  availability_zone       = "${element(var.az, count.index)}"
  count                   = "${length(var.public_subnet_cidr)}"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.customer}-SUB-${var.appname}-${var.envr}-PE"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.customer}-IGW-${var.appname}-${var.envr}"
  }
}

resource "aws_route_table" "pub" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    # count      = "${length(aws_subnet.public_subnet.*.id)}"
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table_association" "pub" {
  #count          = "${length(aws_subnet.public_subnet.*.id)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.pub.id}"
}

# PRIVATE SUBNET
resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(var.private_subnet_cidr, count.index)}"
  availability_zone = "${element(var.az, count.index)}"
  count             = "${length(var.private_subnet_cidr)}"

  tags = {
    Name = "${var.customer}-SUB-${var.appname}-${var.envr}-PR"
  }
}

resource "aws_eip" "nat_ip" {
  vpc   = true
  count = "${length(var.public_subnet_cidr)}"
}

resource "aws_nat_gateway" "nat_eip" {
  count         = "${length(var.public_subnet_cidr)}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  allocation_id = "${element(aws_eip.nat_ip.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.igw"]
}

resource "aws_route_table" "pri" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    # count          = "${length(var.private_subnet_cidr)}"
    cidr_block     = "${element(aws_subnet.private_subnet.*.id, count.index)}"
    nat_gateway_id = "${element(aws_nat_gateway.nat_eip.*.id, count.index)}"
  }
}

resource "aws_route_table_association" "pri" {
  # count          = "${length(var.private_subnet_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.pri.id}"
}

##### Security Groups ######

resource "aws_security_group" "alb" {
  name        = "Allow_Tls"
  description = "Allow TLS"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #     from_port    = ["0-65535"]
  #     to_port      = ["0-65535"]
  #     protocol     = "tcp"
  #     security_groups  = ["${aws_security_group.alb.id}"] 
  # }
}

### Security Group for LC

resource "aws_security_group" "lc" {
  name        = "Allow_Tls"
  description = "Allow TLS"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }
}
