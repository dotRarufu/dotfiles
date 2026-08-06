gst() {
  if [[ $# -eq 0 ]]; then
    git stash push -u
  else
    git stash push -u -m "$*"
  fi
}

gcm() {
  local stickers=""
  local message=""
  local git_flags=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--sticker)
        if [[ -z "$2" ]]; then
          echo "Error: missing sticker value"
          return 1
        fi

        stickers="$stickers[$2] "
        shift 2
        ;;

      --)
        shift
        git_flags=("$@")
        break
        ;;

      *)
        if [[ -z "$message" ]]; then
          message="$1"
        else
          message="$message $1"
        fi
        shift
        ;;
    esac
  done

  if [[ -z "$message" ]]; then
    echo "Usage: gcm [-s sticker] <message> [-- git flags]"
    return 1
  fi

  git commit -m "${stickers}${message}" "${git_flags[@]}"
}


ulc() { git reset --mixed HEAD~1; }

bld() {
  npm run build
}

ga.() {
  git add .
}

gsa() {
  git stash apply
}

gp() {
  git push
}
