provider "docker" {}

resource "docker_network" "data_pipeline_network" {
  name = "data_pipeline_network"
}

# Build PostgreSQL
resource "null_resource" "build_postgres_image" {
  provisioner "local-exec" {
    command = "docker build -t custom_postgres:latest -f Dockerfile-postgres ."
  }
}

# Build Python
resource "null_resource" "build_python_image" {
  provisioner "local-exec" {
    command = "docker build -t custom_python:latest -f Dockerfile-python ."
  }
}

# PostgreSQL container
resource "docker_container" "postgres_container" {
  image = "custom_postgres:latest"
  name  = "postgres_container"
  networks_advanced {
    name = docker_network.data_pipeline_network.name
  }

  env = [
    "POSTGRES_DB=climate_db",
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=postgres"
  ]

  ports {
    internal = 5432
    external = 5432
  }

  volumes {
    container_path = "/docker-entrypoint-initdb.d/init.sql"
    host_path      = abspath("/Users/elishuamcpherson/Downloads/Speedcast/solution/init.sql")
  }

  volumes {
    container_path = "/var/lib/postgresql/data"
    host_path      = abspath("/Users/elishuamcpherson/Downloads/Speedcast/postgres_data")
  }

  depends_on = [null_resource.build_postgres_image]
}

resource "docker_container" "python_container" {
  image = "custom_python:latest"  # Use the custom Python image
  name  = "python_container"
  networks_advanced {
    name = docker_network.data_pipeline_network.name
  }

  depends_on = [
    docker_container.postgres_container,
    null_resource.build_python_image
  ]  # Ensure it depends on the custom Python image build


  volumes {
    container_path = "/app"
    host_path      = abspath("/Users/elishuamcpherson/Downloads/Speedcast/solution")  # Ensure query_script.py exists here
  }

  # keep the container running
  entrypoint = [
    "/bin/sh", "-c", "mkdir -p /app && ls /app && python3 /app/query_script.py && tail -f /dev/null"
  ]
}
