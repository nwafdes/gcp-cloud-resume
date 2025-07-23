
resource "google_firestore_database" "database" {
  project                           = var.project_id
  name                              = var.database_name
  location_id                       = "me-central1"
  type                              = "FIRESTORE_NATIVE"
}


resource "google_firestore_document" "mydoc" {
  project     = var.project_id
  database    = var.database_name
  collection  = var.collection_name
  document_id = var.document
  fields      = "{\"${var.field_name}\" : {\"integerValue\":0}}"
  depends_on = [ google_firestore_database.database ]
}

