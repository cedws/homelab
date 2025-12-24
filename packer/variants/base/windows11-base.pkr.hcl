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

variable "proxmox_storage" {
  type        = string
  description = "Storage pool for VM disks"
}

variable "proxmox_iso_storage" {
  type        = string
  description = "Storage pool for ISO files"
}

variable "vm_id" {
  type        = number
  description = "VM ID"
  default     = 9000
}

variable "vm_name" {
  type        = string
  description = "VM name"
  default     = "windows11-base-template"
}

variable "vm_memory" {
  type        = number
  description = "VM memory in MB"
}

variable "vm_cores" {
  type        = number
  description = "VM CPU cores"
}

variable "vm_disk_size" {
  type        = string
  description = "VM disk size"
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

variable "windows_image_index" {
  type        = string
  description = "Windows image index from ISO"
  default     = "6"
}

variable "windows_computer_name" {
  type        = string
  description = "Computer name"
  default     = "WIN11-TEMPLATE"
}

variable "windows_time_zone" {
  type        = string
  description = "Windows timezone"
  default     = "GMT Standard Time"
}

variable "windows_ui_language" {
  type        = string
  description = "Windows UI language"
  default     = "en-GB"
}

variable "windows_keyboard_layout" {
  type        = string
  description = "Windows keyboard layout"
  default     = "en-GB"
}

variable "virtio_win_version" {
  type        = string
  description = "VirtIO driver version folder (w10, w11, 2k19, 2k22, etc.)"
  default     = "w11"
}

source "proxmox-iso" "windows11-base" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  node                     = var.proxmox_node
  insecure_skip_tls_verify = true

  # VM General Settings
  vm_id                = var.vm_id
  vm_name              = var.vm_name
  template_name        = var.vm_name
  template_description = "Windows 11 Base Template"

  # Boot ISO Configuration
  boot_iso {
    type         = "sata"
    iso_file     = "${var.proxmox_iso_storage}:iso/26100.4349.250607-1500.ge_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_en-gb.iso"
    unmount      = true
    iso_checksum = "none"
  }

  # VirtIO Drivers ISO
  additional_iso_files {
    type         = "sata"
    iso_file     = "${var.proxmox_iso_storage}:iso/virtio-win.iso"
    unmount      = true
    iso_checksum = "none"
  }

  # Autounattend ISO (templated)
  additional_iso_files {
    type             = "sata"
    iso_checksum     = "none"
    iso_storage_pool = var.proxmox_iso_storage
    unmount          = true
    cd_label         = "AUTOUNATTEND"
    cd_content = {
      "autounattend.xml" = templatefile("./autounattend.xml.tpl", {
        username           = var.ssh_username
        password           = var.ssh_password
        computer_name      = var.windows_computer_name
        time_zone          = var.windows_time_zone
        ui_language        = var.windows_ui_language
        keyboard_layout    = var.windows_keyboard_layout
        image_index        = var.windows_image_index
        virtio_win_version = var.virtio_win_version
      })
    }
  }

  # Negative boot_wait starts sending commands immediately
  # Spam returns to bypass "Press any key to boot from CD" and early boot screens
  boot_wait    = "-1s"
  boot_command = [
    "<return><wait><return><wait><return><wait><return><wait><return><wait><return><wait><return><wait><return><wait><return><wait><return><wait>"
  ]

  # VM Hardware Configuration
  os              = "win11"
  bios            = "ovmf"
  machine         = "pc-q35-10.1"
  qemu_agent      = true
  scsi_controller = "virtio-scsi-single"
  cpu_type        = "host"

  cores  = var.vm_cores
  memory = var.vm_memory

  # EFI Configuration
  efi_config {
    efi_storage_pool  = var.proxmox_storage
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  # Disk Configuration
  disks {
    type         = "scsi"
    disk_size    = var.vm_disk_size
    storage_pool = var.proxmox_storage
    format       = "raw"
    io_thread    = true
    discard      = true
    ssd          = true
  }

  # Network Configuration
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # SSH Configuration
  communicator           = "ssh"
  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password
  ssh_timeout            = "4h"
  ssh_handshake_attempts = 100
  ssh_keep_alive_interval = "5s"

  # Timeouts
  task_timeout = "30m"
}

build {
  sources = ["source.proxmox-iso.windows11-base"]

  # Configure network
  provisioner "powershell" {
    script = "./configure-network.ps1"
  }

  # Configure security settings
  provisioner "powershell" {
    script = "./configure-security.ps1"
  }

  # Restart after initial setup
  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  # Disable unnecessary services
  provisioner "powershell" {
    script = "./disable-services.ps1"
  }

  # Final cleanup
  provisioner "powershell" {
    script = "./cleanup.ps1"
  }
}
