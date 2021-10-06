variable "env" {
  description = "environment type"
  type        = string
  default     = "Sarath"
}

variable "vpc-cdir" {
  description = "vpc cidr block"
  type        = string
}
variable "subnet-cdir" {
  description = "cidr blocks for subnets"
  type        = list(string)
}
variable "azs" {
  description = "available AZs"
  type        = list(string)

}