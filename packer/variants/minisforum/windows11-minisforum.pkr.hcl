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
  default     = "https://your-proxmox-host:8006/api2/json"
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox username"
  default     = "root@pam"
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox password"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node name"
  default     = "pve"
}

variable "base_template_name" {
  type        = string
  description = "Base template to clone from (can be name or ID)"
  default     = "windows11-template"
}

variable "vm_id" {
  type        = number
  description = "VM ID"
  default     = 9018
}

variable "vm_name" {
  type        = string
  description = "VM name"
  default     = "windows11-minisforum-template"
}

variable "vm_memory" {
  type        = number
  description = "VM memory in MB"
  default     = 4096
}

variable "vm_cores" {
  type        = number
  description = "VM CPU cores"
  default     = 8
}

variable "proxmox_storage" {
  type        = string
  description = "Storage pool for VM disks"
  default     = "local-lvm"
}

variable "ssh_username" {
  type        = string
  description = "SSH username"
  default     = "Anon"
}

variable "ssh_password" {
  type        = string
  description = "SSH password"
  default     = "Packer123!"
  sensitive   = true
}

source "proxmox-clone" "windows11-minisforum" {
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
  template_description = "Windows 11 Minisforum Template - Radeon GPU startup/shutdown fixes"
  full_clone           = true

  # VM Hardware Configuration (must match base template)
  os              = "win11"
  bios            = "ovmf"
  machine         = "pc-q35-10.1,viommu=virtio"
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
  sources = ["source.proxmox-clone.windows11-minisforum"]

  # Upload Radeon fix batch scripts
  provisioner "file" {
    source      = "./RadeonStartupFix.bat"
    destination = "C:/Windows/Temp/RadeonStartupFix.bat"
  }

  provisioner "file" {
    source      = "./RadeonShutdownFix.bat"
    destination = "C:/Windows/Temp/RadeonShutdownFix.bat"
  }

  # Configure GPO scripts for Radeon fix
  provisioner "powershell" {
    script = "./configure-gpo-scripts.ps1"
  }

  # Finalize (keep user as admin for Minisforum variant)
  provisioner "powershell" {
    script = "./finalize-minisforum.ps1"
  }

  # Final cleanup
  provisioner "powershell" {
    inline = [
      "Write-Host 'Cleaning up...'",
      "Remove-Item -Path 'C:\\Windows\\Temp\\*.bat' -Force -ErrorAction SilentlyContinue",
      "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
    ]
  }
}
