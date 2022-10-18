terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.80.0"
    }
  }
  required_version = ">= 0.13"

backend "s3" {
  endpoint                    = "storage.yandexcloud.net"
  bucket                      = ""
  region                      = "ru-central1-a"
  key                         = "lemp-test/lemp.tfstate"
  access_key                  = ""
  secret_key                  = ""
  skip_region_validation      = true
  skip_credentials_validation = true
  }      
}

provider "yandex" {
  service_account_key_file = file("~/key.json")
  cloud_id                 = ""
  folder_id                = ""
  zone                     = "ru-central1-a"
}

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.2.0/24"]
}


module "ya_instance_1" {
  source                = "./modules/instance"
  instance_family_image = "lemp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet1.id
}

module "ya_instance_2" {
  source                = "./modules/instance"
  instance_family_image = "lamp"
  vpc_subnet_id         = yandex_vpc_subnet.subnet2.id
}

resource "yandex_lb_target_group" "makmos" {
  name      = "target-group"

  target {
    subnet_id = yandex_vpc_subnet.subnet2.id
#    address   = "${yandex_compute_instance.terraform-lamp.network_interface.0.ip_address}"
    address = module.ya_instance_2.internal_ip_address_vm
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet1.id
#    address   = "${yandex_compute_instance.terraform-lemp.network_interface.0.ip_address}"
    address = module.ya_instance_1.internal_ip_address_vm
  }

}

resource "yandex_lb_network_load_balancer" "makmos-lb" {
  name = "makmos-lb"
  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.makmos.id}"
    healthcheck {
      name = "http"
        http_options {
          port = 80
          path = "/"
        }
    }
  }
}
