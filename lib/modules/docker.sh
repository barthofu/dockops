docker_compose_up() {
  path=$(guard path $1) || exit 1
  echo "docker >> Starting (up) docker-compose at $path"

  docker compose -f $path/docker-compose.yml up -d
}

docker_compose_down() {
  path=$(guard path $1) || exit 1
  echo "docker >> Stopping (down) docker-compose at $path"

  docker compose -f $path/docker-compose.yml down
}

docker_compose_pull() {
  path=$(gaurd path $1) || exit 1
  echo "docker >> Pulling docker-compose at $path"

  docker compose -f $path/docker-compose.yml pull
}

docker_compose_reload() {
  path=$(guard path $1) || exit 1
  echo "docker >> Reloading stack $path"

  docker_compose_down $path
  docker_compose_pull $path
  docker_compose_up $path
}
