variable "resource_group_name" {
  default = "project_celia"
}

variable "location" {
  default = "westeurope"
}

variable "vnet" {
  default = "vnet"
}

variable "subnet" {
  default = "subnet"
}

variable "VM-nic"{
    default = "vm-nic"
}

variable "config"{
    default = "ip_config_nic"
}

variable "VM_name"{
    default = "vm-celia"
}

variable "computerVM_name"{
    default = "vm-celia"
}

variable "admin"{
    default = "celia"
}

variable "OSdisk_name"{
    default = "OSdisk"
}

variable "NSG"{
    default = "NSG_group"
}

variable "VM_rule"{
    default = "SSH"
}

variable "VM_rule2"{
    default = "HTTP"
}