#########################
## GCP Linux VM - Main ##
#########################

# Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 4
}

# Bootstrapping Script to Install Apache
data "template_file" "linux-metadata" {
template = <<EOF
sudo apt-get update; 
sudo apt-get install -yq build-essential apache2;
sudo systemctl start apache2;
sudo systemctl enable apache2;
#cloud-config
#runcmd:
#- <%=instance.cloudConfig.agentInstall%>
#- <%=instance.cloudConfig.finalizeServer%>
EOF
}

#data {
#  custom_data = block {
#    value = <<-EOF
#    <%=instance?.cloudConfig?.agentInstallTerraform%>
#    <%=cloudConfig?.finalizeServer%>
#    EOF
#  }
#}


# Create VM
resource "google_compute_instance" "vm_instance_public" {
  name         = "${lower(var.company)}-${lower(var.app_name)}-${var.environment}-vm${random_id.instance_id.hex}"
  machine_type = var.linux_instance_type
  zone         = var.gcp_zone
  hostname     = "${var.app_name}-vm${random_id.instance_id.hex}.${var.app_domain}"
  tags         = ["ssh","http"]
  #custom_data = base64encode(data.custom_data)
  
  boot_disk {
    initialize_params {
      image = var.ubuntu_2004_sku
    }
  }

  metadata_startup_script = <<EOF
    #cloud-config
    runcmd:
    sudo bash -c 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+zlLrb2mbV90frSB/ZJCI9zBa2vCAXI4zItIHF0VoX5ADadXBC3kh8KhMOeMpuf8Plm5A4IDT2l234WkEoF7E2/1TAh5DC/hyMT5FI8hKM89o4xcXvIrC+091rA1O4LyimXRDN2W0gpxUOQ8JaDaHzt3FNEd2Qq8rTr+m+XWUmnJLGw1F2O1gArccW6G6UI9CvGkhh3+gt4E5ZHnKh0jqwvhMpr/2coXv5PWWi55f/MgYkxEBIX65ou2mqCW13ob9jQz0998o6Oy9SGjXFCZZjaxfLJnfHnC/ZqfqtQw5C3SzU8iYh1vOwldxCDrwe48ZMTZ/9XT5HbKwjVrddWdz google-ssh {"userName":"deepti.gaharwar@gmail.com"}" >> /home/deepti_gaharwar/.ssh/authorized_keys'
    sudo bash -c '<%=instance?.cloudConfig?.agentInstall%> | tee /home/deepti_gaharwar/agentInstall.log'
    sudo bash -c '<%=instance?.cloudConfig?.finalizeServer%> | tee /home/deepti_gaharwar/finalizeServer.log'
    EOF

  network_interface {
    network       = google_compute_network.vpc.name
    subnetwork    = google_compute_subnetwork.network_subnet.name
    access_config { }
  }
}
