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

gca() {
  local message=()
  local args=()

  while [[ $# -gt 0 ]]; do
    if [[ "$1" == "--" ]]; then
      shift
      args=("$@")
      break
    fi

    message+=("$1")
    shift
  done

  if [[ ${#message[@]} -eq 0 ]]; then
    echo "Usage: gca <commit message> [-- <git commit --amend args>]"
    return 1
  fi

  git commit --amend -m "${message[*]}" "${args[@]}"
}

gex() {
    local file=".git/info/exclude"
    local command="${1:-}"
    local entry="${2:-}"

    if [[ ! -d .git ]]; then
        echo "Error: not a Git repository"
        return 1
    fi

    case "$command" in
        add)
            if [[ -z "$entry" ]]; then
                echo "Usage: gex add <file-or-pattern>"
                return 1
            fi

            if grep -Fxq "$entry" "$file" 2>/dev/null; then
                echo "Already excluded: $entry"
                return 0
            fi

            echo "$entry" >> "$file"
            echo "Excluded: $entry"
            ;;

        remove|rm)
            if [[ -z "$entry" ]]; then
                echo "Usage: gex remove <file-or-pattern>"
                return 1
            fi

            if ! grep -Fxq "$entry" "$file" 2>/dev/null; then
                echo "Not found: $entry"
                return 0
            fi

            grep -Fxv "$entry" "$file" > "$file.tmp" &&
                mv "$file.tmp" "$file"

            echo "Removed: $entry"
            ;;

        list|ls)
            if [[ ! -f "$file" ]]; then
                echo "No locally excluded files."
                return 0
            fi

            local entries
            entries=$(grep -vE '^[[:space:]]*(#|$)' "$file")

            if [[ -z "$entries" ]]; then
                echo "No locally excluded files."
            else
                echo "$entries"
            fi
            ;;

        *)
            echo "Usage:"
            echo "  gex add <file-or-pattern>"
            echo "  gex remove <file-or-pattern>"
            echo "  gex list"
            return 1
            ;;
    esac
}
