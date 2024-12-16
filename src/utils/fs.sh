fs_directory_exists() {
    path=$1
    if [ -d "$path" ]; then
        return 0
    else
        return 1
    fi
}