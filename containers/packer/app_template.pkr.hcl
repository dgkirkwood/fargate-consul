variable "app_name" {
  description = "The name of the application"
  default = "p-frontend"
}
variable "app_port" {
  description = "The app port"
  default = "5000"
}
variable "app_path" {
  description = "The source path of the application"
  default = "../frontend"
}

source "docker" "python" {
  image = "python:alpine3.7"
  commit= true
  changes= [
    "ENTRYPOINT [\"/bin/sh\", \"-c\", \"python /app/${var.app_name}.py\"]",
    "WORKDIR /app",
    "EXPOSE ${var.app_port}",
    "LABEL version=0.1"
  ]
}

build {
  sources = ["source.docker.python"]
  provisioner "shell" {
      inline = ["mkdir /app"]
  }
  provisioner "file" {
      source = "${var.app_path}/"
      destination = "/app"
  }
  provisioner "shell" {
      inline = ["pip install -r /app/requirements.txt"]
  }
  post-processor "docker-tag" {
    repository= "dgkirkwood/${var.app_name}"
    tag = ["testing"]
  }
  post-processor "docker-push" {
  }
}
