module "vpc" {
  source = "../../modules/vpc"
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs = var.app_subnet_cidrs
  data_subnet_cidrs = var.data_subnet_cidrs
}

module "sg" {
  source = "../../modules/sg"
  vpc_id = module.vpc.vpc_id
}

