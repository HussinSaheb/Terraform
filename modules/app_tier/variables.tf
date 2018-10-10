variable "vpc_id" {
  description = "id of the vpc"
}

variable "app_ami_id" {
  default = "ami-0f0e960cbe148a24f"
}

variable "dbip" {
  description = "id of the db"
}

variable "igid" {
  description = "id of the internet gateway"
}

variable "user_data" {
  description = "data to add"
}
