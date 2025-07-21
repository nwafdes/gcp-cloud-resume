resource "google_project" "project" {
  project_id = "project-id"
  name       = "project-id"
  org_id     = "123456789"
  deletion_policy = "DELETE"
}