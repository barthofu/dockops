infisical_start_agent() {
    config_path=$(guard config_path $1) || exit 1

    cd $(dirname $config_path)
    sudo infisical agent --config $(basename $config_path) &
}