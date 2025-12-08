packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_url" {
  type        = string
  description = "Proxmox API URL"
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox username"
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox password"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
}

variable "base_template_name" {
  type        = string
  description = "Base template to clone from (can be name or ID)"
  default     = "windows11-base-template"
}

variable "vm_id" {
  type        = number
  description = "VM ID"
  default     = 9001
}

variable "vm_name" {
  type        = string
  description = "VM name"
  default     = "windows11-gaming-template"
}

variable "vm_memory" {
  type        = number
  description = "VM memory in MB"
}

variable "vm_cores" {
  type        = number
  description = "VM CPU cores"
}

variable "proxmox_storage" {
  type        = string
  description = "Storage pool for VM disks"
}

variable "ssh_username" {
  type        = string
  description = "SSH username"
}

variable "ssh_password" {
  type        = string
  description = "SSH password"
  sensitive   = true
}

source "proxmox-clone" "windows11-gaming" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  node                     = var.proxmox_node
  insecure_skip_tls_verify = true

  # Clone Settings
  clone_vm             = var.base_template_name
  vm_id                = var.vm_id
  vm_name              = var.vm_name
  template_name        = var.vm_name
  template_description = "Windows 11 Gaming Template"
  full_clone           = true

  # VM Hardware Configuration (must match base template)
  os              = "win11"
  bios            = "ovmf"
  machine         = "pc-q35-10.1"
  qemu_agent      = true
  scsi_controller = "virtio-scsi-single"
  cpu_type        = "host"
  cores           = var.vm_cores
  memory          = var.vm_memory

  # EFI Configuration
  efi_config {
    efi_storage_pool  = var.proxmox_storage
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  # Network Configuration
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # SSH Configuration
  communicator = "ssh"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "30m"

  # Timeouts
  task_timeout = "20m"
}

build {
  sources = ["source.proxmox-clone.windows11-gaming"]

  # Remove bloatware first
  provisioner "powershell" {
    script = "./remove-bloatware.ps1"
  }

  # Install Scoop package manager
  provisioner "powershell" {
    script = "./install-scoop.ps1"
  }

  # Install applications via winget
  provisioner "powershell" {
    script = "./install-apps.ps1"
  }

  # Install NextDNS
  provisioner "powershell" {
    script = "./install-nextdns.ps1"
  }

  # Configure applications
  provisioner "powershell" {
    script = "./configure-apps.ps1"
  }

  # Configure Windows settings
  provisioner "powershell" {
    script = "./configure-windows.ps1"
  }
}
