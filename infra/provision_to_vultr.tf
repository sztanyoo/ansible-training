# Usage: export VULTR_API_KEY=12345678; terraform apply


variable "instance_count" {
  default = "1"
}

provider "vultr" {
  rate_limit  = 700
  retry_limit = 3
  version = "1.4.1"
}


resource "vultr_server" "kube_server" {
  count         = "${var.instance_count}"
  plan_id   = "203"
  region_id = "24" # 24=Paris, 9=Frankfurt
  os_id     = "387"  # 387 for Ubuntu 20.04
  label     = "ansible-${count.index + 1}"
  hostname  = "ansible-${count.index + 1}"
  enable_ipv6     = false
  auto_backup     = false
  ddos_protection = false
  notify_activate = true
  script_id       = vultr_startup_script.ansible_installer.id
  ssh_key_ids     = [vultr_ssh_key.kube_ssh_key.id]
  firewall_group_id = vultr_firewall_group.kube_firewall.id
  depends_on = [vultr_startup_script.ansible_installer]
}

resource "vultr_startup_script" "ansible_installer" {
  name = "ansible_installer"
  script = file("install_ansible.sh")
}

resource "vultr_firewall_group" "kube_firewall" {
    description = "ansible firewall"
}

resource "vultr_firewall_rule" "kube_firewall_ping" {
    firewall_group_id = vultr_firewall_group.kube_firewall.id
    protocol = "icmp"
    network = "0.0.0.0/0"
}

resource "vultr_firewall_rule" "kube_firewall_all" {
    firewall_group_id = vultr_firewall_group.kube_firewall.id
    protocol = "tcp"
    network = "0.0.0.0/0"
    from_port = 1
    to_port = 65535
}
resource "vultr_ssh_key" "kube_ssh_key" {
  name = "kube_ssh_key"
  ssh_key = file("id_rsa_ansible.pub")
}

output "server_ip" {
  value = vultr_server.kube_server[0].main_ip
}
