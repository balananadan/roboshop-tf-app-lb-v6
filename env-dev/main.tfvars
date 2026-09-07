
env      = "dev"
location = "Denmark East"
rgname   = "Nothing"
image_id = "/subscriptions/67d6c4c6-913c-4f47-b3e1-eab7b50d229d/resourceGroups/Nothing/providers/Microsoft.Compute/galleries/Ice/images/1.1.1/versions/1.1.1"

db = {
  mysql = {}
  # valkey   = {}
  # mongodb  = {}
  # rabbitmq = {}
}

apps = {
  catalogue = {
    port = 8002
  }
  # user         = {
  #   port = 8001
  # }
  # cart         = {
  #   port = 8003
  # }
  # shipping     = {
  #   port = 8004
  # }
  # order        = {
  #   port = 8007
  # }
  # notification = {
  #   port = 8008
  # }
  # ratings      = {
  #   port = 8006
  # }
  # payment      = {
  #   port = 8005
  #}
}

ui = {
  frontend = {
    port = 80
  }
}