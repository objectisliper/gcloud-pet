provider "google" {
 credentials = file("CREDENTIALS_FILE.json")
 project     = "gcloud-pet"
 region      = "us-west1"
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Compute Engine instance
resource "google_compute_instance" "default" {
 name         = "flask-vm-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "us-west1-a"

 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip python3 python3-dev python3-venv rsync; pip install --upgrade pip; pip install -r requirements.txt; python app.py"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }

 metadata = {
   ssh-keys = "ppolu:${file("~/.ssh/id_rsa.pub")}"
 }

}

resource "google_compute_firewall" "default" {
 name    = "flask-app-firewall"
 network = "default"

 allow {
   protocol = "tcp"
   ports    = ["5000"]
 }
}


// A variable for extracting the external IP address of the instance
output "ip" {
 value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
