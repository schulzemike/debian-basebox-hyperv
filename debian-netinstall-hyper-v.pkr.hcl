packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1"
    }
    sshkey = {
      version = "~> 1"
      source = "github.com/ivoronin/sshkey"
    }
    vagrant = {
      version = "~> 1"
      source = "github.com/hashicorp/vagrant"
    }
  }
}

variable "debian_version" {
  type    = string
  default = "12.9.0"
}

data "sshkey" "vagrant" {
  name = "vagrant_id"
}

source "hyperv-iso" "debian-builder" {
  boot_command         = [
		"c",	
		"linux /install.amd/vmlinuz auto=true priority=critical url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg --- quiet<enter>",
		"initrd /install.amd/initrd.gz<enter>",
        "boot<enter>"
						]
  boot_wait            = "4s"
  cpus                 = 5
  communicator         = "ssh"
  disk_size            = 20000
  enable_secure_boot   = false
  generation           = 2
  headless             = false
  http_directory       = "./srv"
  iso_checksum         = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA512SUMS"
  iso_url              = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-${var.debian_version}-amd64-netinst.iso"
  shutdown_command     = "sudo shutdown -P now"
  disable_shutdown     = false
  ssh_username         = "vagrant"
  ssh_password         = "vagrant"
  ssh_timeout          = "15m"
  switch_name          = "Default Switch"
}

build {
  sources = ["source.hyperv-iso.debian-builder"]
 
    provisioner "shell" {
 	  script          = "provision/config-xrdp.sh"
	  execute_command = "echo 'packer' | sudo -S env {{ .Vars }} {{ .Path }}"
    }
	
	provisioner "shell" {
	  inline = [
		"#!/bin/bash -e",
	    "echo 'Saving public SSH key for vagrant user...'",
	    "[[ -d /home/vagrant/.ssh ]] || mkdir /home/vagrant/.ssh",
		"echo ${data.sshkey.vagrant.public_key} > /home/vagrant/.ssh/authorized_keys"
	]
  }
 
    post-processor "vagrant" {
	  architecture         = "amd64"
 	  output               = "output/my-debian-base.box"
	  keep_input_artifact  = false
	  provider_override    = "hyperv"
	  vagrantfile_template = "vagrant/Vagrantfile"
	  include              = [
                               "packer_cache/ssh_private_key_vagrant_id_rsa.pem"					   
	                         ]
   }
}
