declare -a IGNORED_FILES=("dockops.sh" "dockops_restart.sh" "loader.sh")

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# source a file if it's not in the IGNORED_FILES array
source_file() {
	file_path=$1
	for element in "${IGNORED_FILES[@]}"; do
		if [[ "$file_path" =~ $element ]]; then
			return
		fi
	done
	source $file_path
}

# read all the .sh files in $DIR recursively and source them
while read file_path; do source_file $file_path; done < <(find $DIR/../.. -name '*.sh' -type f)
