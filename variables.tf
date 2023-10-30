variable "project_id" {
  description = "The ID of the project to apply any resources to."
  type        = string
}

variable "cloud_region" {
  description = "The region to deploy to."
  type        = string
}

variable "zone" {
  description = "Cloud zone"
  type        = string
}

variable "service_name" {
  description = "Name of the Cloud Run service."
  type        = string
}

variable "image_url" {
  description = "URL of the Docker image to deploy."
  type        = string
}

variable "aspnetcore_environment" {
  description = "Environment name."
  type        = string
}

variable "aspnetcore_urls" {
  description = "ASP.NET Core URLs."
  type        = list(string)
}

variable "mongodb_url" {
  description = "MongoDB URL."
  type        = string
}

variable "mongodb_database" {
  description = "MongoDB database name."
  type        = string
}

variable "query_structure_collection_name" {
  description = "Query structure collection name."
  type        = string
}

variable "query_structure_sequence_collection_name" {
  description = "Query structure sequence collection name."
  type        = string
}

variable "client_collection_name" {
  description = "Client collection name."
  type        = string
}

variable "client_sequence_collection_name" {
  description = "Client sequence collection name."
  type        = string
}

variable "tz" {
  description = "Timezone."
  type        = string
}
