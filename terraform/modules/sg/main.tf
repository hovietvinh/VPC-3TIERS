// public
resource "aws_security_group" "public_sg" {
  name        = "Public SG"
  description = "Allow HTTP and HTTPS traffic from Internet"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Public SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_http_public_sg" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ingress_https_public_sg" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

// app
resource "aws_security_group" "app_sg" {
  name        = "App SG"
  description = "Allow HTTP and HTTPS traffic from Public SG"
  vpc_id      = var.vpc_id

  tags = {
    Name = "App SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_http_app_sg" {
  security_group_id = aws_security_group.app_sg.id
  referenced_security_group_id         = aws_security_group.public_sg.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ingress_https_app_sg" {
  security_group_id = aws_security_group.app_sg.id
  referenced_security_group_id         = aws_security_group.public_sg.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "app_allow_all_outbound" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

// data
resource "aws_security_group" "data_sg" {
  name        = "Data SG"
  description = "Allow MySQL access from App SG only"
  vpc_id      = var.vpc_id

  tags = {
    Name = "Data SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_data_sg" {
  security_group_id = aws_security_group.data_sg.id
  referenced_security_group_id         = aws_security_group.app_sg.id
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "data_allow_all_outbound" {
  security_group_id = aws_security_group.data_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

