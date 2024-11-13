variable "ssh_key_path" {
  description = "The path to private key"
  type        = string
}

resource "scaleway_instance_security_group" "excalidraw_sg" {
  name = "excalidraw-security-group"

  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action   = "accept"
    port     = "22"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }

  inbound_rule {
    action   = "accept"
    port     = "5000"
    ip_range = "0.0.0.0/0"
    protocol = "TCP"
  }
}

resource "scaleway_instance_ip" "excalidraw_ip" {
  tags = ["excalidraw"]
}

resource "scaleway_instance_server" "excalidraw" {
  name         = "excalidraw-instance"
  type         = "DEV1-S"
  image        = "ubuntu_focal"
  tags         = ["excalidraw"]

  security_group_id = scaleway_instance_security_group.excalidraw_sg.id

  root_volume {
    size_in_gb = 20
  }

  ip_id = scaleway_instance_ip.excalidraw_ip.id
  provisioner "remote-exec" {
  inline = [
    "sudo apt-get update -y",
    "sudo apt-get install -y docker.io docker-compose",
    "sudo docker run -d --name excalidraw -p 5000:80 -e NODE_ENV=production --restart unless-stopped excalidraw/excalidraw:latest"
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_key_path)
    host        = scaleway_instance_ip.excalidraw_ip.address
    }
  }

}


output "excalidraw_instance_ip" {
  value = scaleway_instance_ip.excalidraw_ip.address
}

