
variable "app_name" {
  description = "The name of the application"
}
variable "app_path" {
  description = "The source path of the application"
}


source "docker" "envoy" {
  image = "envoyproxy/envoy-alpine:v1.13.2"
  commit= true
  changes= [
    "ENTRYPOINT [\"/bin/sh\", \"-c\", \"/entrypoint.sh\"]",
    "LABEL version=0.1",
    "ENV SERVICE_CONFIG /opt/consul/services",
    "ENV CONSUL_HTTP_ADDR=http://localhost:8500"
  ]
}

build  {

  sources = ["source.docker.envoy"]
  provisioner "shell" {
    inline = [
          "mkdir /opt/consul",
          "mkdir /opt/consul/config && mkdir /opt/consul/data && mkdir /opt/consul/services",
          "apk add -u bash curl",
          "wget https://releases.hashicorp.com/consul/1.8.0/consul_1.8.0_linux_amd64.zip -O /tmp/consul.zip",
          "unzip /tmp/consul.zip -d /tmp",
          "mv /tmp/consul /usr/local/bin/consul"
    ]
  }
  provisioner "file" {
      source = "${var.app_name}-entrypoint.sh"
      destination = "/entrypoint.sh"
  }
  provisioner "file" {
      source = "consulagent_config.json"
      destination = "/opt/consul/config/consulagent_config.json"
  }
  provisioner "file" {
      source = "${var.app_path}/${var.app_name}-service.json"
      destination = "/opt/consul/services/${var.app_name}-service.json"
  }
  provisioner "shell" {
      inline = ["chmod +x /entrypoint.sh"]

  }
  post-processor "docker-tag" {
    repository= "dgkirkwood/${var.app_name}-consul-agent"
    tag = ["testing"]
  }
  post-processor "docker-push" {
  }
}

