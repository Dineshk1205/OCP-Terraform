#### RETRIEVE DATA INFORMATION ON VCENTER ####

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

# If you don't have any resource pools, put "Resources" after cluster name
data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_resource_pool}"
  datacenter_id = data.vsphere_datacenter.dc.id
}
# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = "${var.vsphere_datastore}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = "${var.vsphere_network}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = "${var.Template_Name}"
  datacenter_id = data.vsphere_datacenter.dc.id
  
}
#### VM CREATION ####

# Set vm parameters
resource "vsphere_virtual_machine" "openshift" {
  name             = "${var.VM_NAME}"
  num_cpus         = "${var.CPUS}"
  memory           = "${var.Memory}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  firmware         = data.vsphere_virtual_machine.template.firmware
  # Set network parameters
  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # Use a predefined vmware template as main disk
  disk {
    label = "vm-one.vmdk"
    size = "${var.VMDISK_SIZE}"
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "${var.Host_Name}"
        domain    = "${var.Domain_Name}"
      }

      network_interface {
        ipv4_address    = "${var.VM_IP}"
        ipv4_netmask    = "${var.NETMASK}"
        dns_server_list = ["${var.DNS_SERVER}"]
      }

      ipv4_gateway = "${var.Gateway}"
    }
  }
   provisioner "remote-exec" {
    script = "scripts/ocp.sh"
    on_failure = continue
    connection {
      type     = "ssh"
      user     = "root"
      password = "${var.vsphere_password}"
      host     = vsphere_virtual_machine.openshift.default_ip_address
    }
      }

}

