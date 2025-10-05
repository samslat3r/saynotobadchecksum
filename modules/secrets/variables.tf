variable "name_prefix" { description = "Name prefix" type = string }
variable "vt_api_key" { description = "VirusTotal API key" type = string  sensitive = true }
variable "presign_api_key" { description = "Presign API key" type = string  sensitive = true }