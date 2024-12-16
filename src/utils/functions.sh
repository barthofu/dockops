guard() {
    param_name=$1
	param=$2
	if [ -z "$param" ]; then
        echo "$param_name is missing"
        sleep 1
	fi
	echo $param
}