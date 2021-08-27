source "qemu" "centos7" {
  format            = "raw"  # "qcow2"
  accelerator       = "kvm"

  iso_url           = "http://centos.ufes.br/7/isos/x86_64/CentOS-7-x86_64-NetInstall-2009.iso"
  iso_checksum      = "md5:0ce8e06655e9fd2bbf9f4793f940925f"
  http_directory    = "srvcfg"

  net_device        = "virtio-net"
  disk_interface    = "virtio"
  memory            = 1024

  ssh_username      = "root"
  ssh_timeout       = "20m"

  shutdown_command  = "echo 'packer' | sudo -S shutdown -P now"
  boot_wait         = "10s"
  boot_command      = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos7-ks.cfg<enter><wait>"]

  # output_directory  = "output_centos"
  # vm_name           = "centos"
}

locals {
  image_sizes = [8]
}

local "root_pass" {
  sensitive = true
  expression = "MVd0m<0r:G.F47H3R"
}

source "null" "example" {
  communicator = "none"
}

build {

  name = "centos7-docker" 

  # sources = ["null.example"]

  # source "qemu.centos7" {
  #   name = "centos7-4G"
  #   disk_size = "4096M"
  #   ssh_password = "${local.root_pass}"
  #   output_directory  = "output-${build.name}-4G"
  # }

  dynamic "source" {
    for_each = local.image_sizes
    iterator = it
    labels   = ["qemu.centos7"]
    content {
      name = "centos7-${it.value}G"
      vm_name = "centos7-${it.value}G"
      disk_size = "${1024 * it.value}M"
      ssh_password = local.root_pass
    }
  }

  provisioner "shell-local" {
    environment_vars = ["TESTVAR=${build.PackerRunUUID}"]
    inline = ["echo source.name is ${source.name}.",
              "echo build.name is ${build.name}.",
              "echo build.PackerRunUUID is $TESTVAR"]
  }

  provisioner "shell" {
    inline = [
      "sleep 10",

      # "sudo yum -y update",
      # "sudo yum -y install epel-release",
      # "sudo yum -y repolist",

      # "sudo yum -y install python-pip",
      # "sudo pip install docker-compose",

      # Docker Compose
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
    ]
  }

}
