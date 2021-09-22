variable "nw-us" {
  type = object({
    leader = object({
      public_ip = string
      private_ip = string
      private_key = string
    })
    worker = object({
      public_ip = string
      private_ip = string
      private_key = string
    })
  })
}