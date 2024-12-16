git_checkout() {
  branch=$(guard branch $1) 
  repo_local_path="${2:-.}"
  echo "git >> Checking out branch $branch on repo $repo_local_path"

  git -C $repo_local_path checkout $branch
}

git_pull() {
  branch="${1:-main}" 
  repo_local_path="${2:-.}" 
  origin="${3:-origin}"
  echo "git >> Pulling repo $repo_local_path"

  git -C "$repo_local_path" pull $origin $branch
}

git_force_pull() {
  branch="${1:-main}" 
  repo_local_path="${2:-.}" 
  origin="${3:-origin}"
  echo "git >> Force pulling repo $repo_local_path"

  git -C "$repo_local_path" reset --hard HEAD~1
  git -C "$repo_local_path" pull $origin $branch
}

git_stash() {
  repo_local_path="${1:-.}"
  echo "git >> Stashing repo $repo_local_path"

  git -C "$repo_local_path" add -A
  git -C "$repo_local_path" add .
  git -C "$repo_local_path" stash
}

git_clone() {
  remote_url="$1" local_destination_path="$2"
  echo "git >> Cloning repo $remote_url to $local_destination_path"

  git clone "$remote_url" "$local_destination_path"
}

# Usage:
# git_sparse_clone <remote_url> <branch> <local_destination_path> <subdir1> <subdir2> ... 
# e.g: git_sparse_clone "http://github.com/tj/n" "main" "./local/location" "/bin"
git_sparse_clone() (
  remote_url="$1" branch="$2" local_destination_path="$3" && shift 3
  echo "git >> Sparse cloning repo $remote_url on branch $branch to $local_destination_path"

  mkdir -p "$local_destination_path"
  cd "$local_destination_path"

  git init
  git branch -m $branch
  git remote add -f origin "$remote_url"

  git config core.sparseCheckout true

  # Loops over remaining args
  for i; do
    echo "/$i" >> .git/info/sparse-checkout
  done

  git pull origin $branch
)