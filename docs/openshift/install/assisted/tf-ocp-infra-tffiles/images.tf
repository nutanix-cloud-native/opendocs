resource "nutanix_image" "rhocs" {
  name        = "RHOCS"
  description = "RHOCS"
  source_uri  = var.image_uri
}