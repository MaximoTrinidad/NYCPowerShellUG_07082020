# Docker Compose Yaml for scaling

This particular sample file is intended to create a multiple instances of SQL Server 2019.
*Note: Make sure the image name match what's in the Yaml file

## Run Docker-Compose configuration scaling Sql Server instances:
docker-compose up -d --scale ms-sql=4
