#====Security Group====
resource "alicloud_security_group" "example_sg" {
  name        = "example-sg"
  description = "auto create sg using terraform"
  vpc_id      = alicloud_vpc.vpc_auto.id
}
resource "alicloud_security_group_rule" "example_sg_config" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  priority          = 1
  security_group_id = alicloud_security_group.example_sg.id
  cidr_ip           = "0.0.0.0/0"
  port_range        = "1/65535"
}

#=======ECS=======
resource "alicloud_instance" "ecs_public" {
  security_groups            = [alicloud_security_group.example_sg.id]
  instance_type              = "ecs.t5-c1m1.large"
  image_id                   = var.image //migration image
  vswitch_id                 = alicloud_vswitch.public_cidr.id
  internet_max_bandwidth_out = 10
  key_name                   = "public_key"
  instance_name              = "ecs-public"
}

resource "alicloud_instance" "ecs_private_1" {
  security_groups = [alicloud_security_group.example_sg.id]
  instance_type   = "ecs.t5-c1m1.large"
  image_id        = "m-k1ah56g2f9zrerflqehz"
  vswitch_id      = alicloud_vswitch.private_cidr.id
  instance_name   = "ecs-private"
  key_name        = "public_key"
}


resource "alicloud_instance" "ecs_private_2" {
  security_groups = [alicloud_security_group.example_sg.id]
  instance_type   = "ecs.c6.large"
  image_id        = "m-k1ah56g2f9zrerflqehz"
  vswitch_id      = alicloud_vswitch.private_cidr_2.id
  instance_name   = "ecs-private"
  key_name        = "public_key"
}


