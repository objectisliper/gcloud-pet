provider "google" {
 credentials = file("CREDENTIALS_FILE.json")
 project     = "gcloud-pet"
 region      = "us-west1"
}
