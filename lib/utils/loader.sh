SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
if [ ! -d "$SCRIPT_DIR" ]; then DIR="$PWD"; fi

# source a file if it's not in the IGNORED_FILES array
source_file() {
	file_path=$1
	if [[ "$file_path" =~ "loader.sh" ]]; then
		return
	fi
	source $file_path
}

# read all the .sh files in $DIR recursively and source them
while read file_path; do source_file $file_path; done < <(find $SCRIPT_DIR/lib -name '*.sh' -type f)