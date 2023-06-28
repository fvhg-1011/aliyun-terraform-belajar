#vpc
resource "alicloud_vpc" "vpc_auto" {
  vpc_name   = "vpc_auto"
  cidr_block = "10.0.0.0/16"
}

#==============subnet==============================
#subnet public
resource "alicloud_vswitch" "public_cidr" {
  vswitch_name = "public_1"
  cidr_block   = "10.0.1.0/28"
  vpc_id       = alicloud_vpc.vpc_auto.id
  zone_id      = "ap-southeast-5a"
}

# subnet private
resource "alicloud_vswitch" "private_cidr" {
  vswitch_name = "private_compute_1"
  cidr_block   = "10.0.1.16/28"
  vpc_id       = alicloud_vpc.vpc_auto.id
  zone_id      = "ap-southeast-5b"
}

# subnet private
resource "alicloud_vswitch" "private_cidr_2" {
  vswitch_name = "private_compute_2"
  cidr_block   = "10.0.1.32/28"
  vpc_id       = alicloud_vpc.vpc_auto.id
  zone_id      = "ap-southeast-5c"
}
#==============NATGateway=====================
#eip
resource "alicloud_eip" "auto_elastic_ip" {
  bandwidth            = "10"
  internet_charge_type = "PayByBandwidth"
  address_name         = "auto_elastic_ip"
}

resource "alicloud_nat_gateway" "auto_nat_gateway" {
  vpc_id           = alicloud_vpc.vpc_auto.id
  nat_gateway_name = "auto_nat_gateway"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.private_cidr.id
  nat_type         = "Enhanced"
}

resource "alicloud_eip_association" "eip_binding" {
  allocation_id = alicloud_eip.auto_elastic_ip.id
  instance_id   = alicloud_nat_gateway.auto_nat_gateway.id
  depends_on    = [alicloud_nat_gateway.auto_nat_gateway, alicloud_eip.auto_elastic_ip]
}
resource "alicloud_snat_entry" "snat_entry_public" {
  depends_on        = [alicloud_eip.auto_elastic_ip, alicloud_eip_association.eip_binding, alicloud_nat_gateway.auto_nat_gateway]
  snat_table_id     = alicloud_nat_gateway.auto_nat_gateway.snat_table_ids
  source_vswitch_id = alicloud_vswitch.public_cidr.id
  snat_ip           = alicloud_eip.auto_elastic_ip.ip_address
}
resource "alicloud_snat_entry" "snat_entry_private" {
  depends_on        = [alicloud_eip.auto_elastic_ip, alicloud_eip_association.eip_binding, alicloud_nat_gateway.auto_nat_gateway]
  snat_table_id     = alicloud_nat_gateway.auto_nat_gateway.snat_table_ids
  source_vswitch_id = alicloud_vswitch.private_cidr.id
  snat_ip           = alicloud_eip.auto_elastic_ip.ip_address
}

resource "alicloud_snat_entry" "snat_entry_private_2" {
  depends_on        = [alicloud_eip.auto_elastic_ip, alicloud_eip_association.eip_binding, alicloud_nat_gateway.auto_nat_gateway]
  snat_table_id     = alicloud_nat_gateway.auto_nat_gateway.snat_table_ids
  source_vswitch_id = alicloud_vswitch.private_cidr_2.id
  snat_ip           = alicloud_eip.auto_elastic_ip.ip_address
}
