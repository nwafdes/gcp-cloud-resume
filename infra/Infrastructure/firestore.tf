resource "google_firestore_database" "database" {
  project                           = "The-cloud-Resume-Challenge"
  name                              = var.database_name
  location_id                       = "me-central1"
  type                              = "FIRESTORE_NATIVE"
}

resource "google_firestore_document" "mydoc" {
  project     = google_project.project.project_id
  database    = google_firestore_database.database.name
  collection  = "somenewcollection"
  document_id = "my-doc-id"
  fields      = "{\"something\":{\"mapValue\":{\"fields\":{\"akey\":{\"stringValue\":\"avalue\"}}}}}"
}