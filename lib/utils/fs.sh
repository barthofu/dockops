fs_directory_exists() {
    path=$(guard path $1) || exit 1
    if [ -d "$path" ]; then
        return 0
    else
        return 1
    fi
}