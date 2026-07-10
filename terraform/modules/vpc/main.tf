resource "aws_vpc" "this" {
  tags = {
    Name = "VPC 3 tiers"
  }
  cidr_block = "10.0.0.0/16"
}

// public
resource "aws_subnet" "public" {
    count                   = length(var.public_subnet_cidrs)
    vpc_id                  = aws_vpc.this.id
    cidr_block              = var.public_subnet_cidrs[count.index]
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true

    tags = {
        Name = "public-subnet-${data.aws_availability_zones.available.names[count.index]}"
    }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public-rtb" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = {
       Name = "public-rtb"
    }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  
  route_table_id = aws_route_table.public-rtb.id 
}

// app
resource "aws_subnet" "app" {
  count                   = length(var.app_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
        Name = "app-subnet-${data.aws_availability_zones.available.names[count.index]}"
    }
}
resource "aws_eip" "eip_nat" {
  domain = "vpc"
  
  tags = {
    Name = "single-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.eip_nat.id
  availability_mode = "zonal"
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "NAT"
  }
  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "app-rtb" {
  vpc_id                  = aws_vpc.this.id
  route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = {
       Name = "app-private-rtb"
    }
}

resource "aws_route_table_association" "app" {
  count = length(var.app_subnet_cidrs)

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app-rtb.id
}

// data
resource "aws_subnet" "data" {
  count                   = length(var.data_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.data_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
        Name = "data-subnet-${data.aws_availability_zones.available.names[count.index]}"
    }

}


resource "aws_route_table" "data-rtb" {
  vpc_id                  = aws_vpc.this.id
  route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = {
       Name = "data-private-rtb"
    }
}

resource "aws_route_table_association" "data" {
  count = length(var.data_subnet_cidrs)

  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data-rtb.id
}