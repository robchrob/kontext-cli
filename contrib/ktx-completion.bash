_ktx_visible_dirs() {
  local cur=$1 d
  COMPREPLY=()
  [[ -z $cur ]] && COMPREPLY+=(".")
  while IFS= read -r d; do
    [[ ${d##*/} == .* ]] && continue
    if git -C "$d" rev-parse --is-inside-work-tree &>/dev/null; then
      [[ -n $(git -C "$d" ls-files --cached --others \
        --exclude-standard 2>/dev/null | head -n1) ]] || continue
    fi
    COMPREPLY+=("$d")
  done < <(compgen -d -- "$cur")
}

_ktx_completions() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local builtin_types="default js py"
  local flags="-h --help -v --version -o --output -l --limit -r --randomize
    -n --dry-run -T --no-tree -t --trace -tt -c --config --no-clip
    --no-agents --raw"
  local long_flags="--output --limit --randomize --dry-run --no-tree
    --trace --config --no-clip --no-agents --raw --help --version"

  local ktxrc="" i
  local dir="."
  for (( i=1; i<${#COMP_WORDS[@]}; i++ )); do
    [[ ${COMP_WORDS[i]} == [-+.]* ]] && continue
    if [[ -d ${COMP_WORDS[i]} ]]; then dir=${COMP_WORDS[i]}; break; fi
  done

  local prev=""
  while true; do
    [[ -f "$dir/.ktxrc" ]] && { ktxrc="$dir/.ktxrc"; break; }
    [[ "$dir" == "/" || "$dir" == "$prev" ]] && break
    prev=$dir; dir=$(dirname "$dir")
  done

  local custom_types=""
  if [[ -n $ktxrc ]]; then
    while IFS= read -r line; do
      [[ $line =~ ^\[type:([a-zA-Z0-9_-]+)\]$ ]] && \
        custom_types+=" ${BASH_REMATCH[1]}"
    done < "$ktxrc"
  fi

  if [[ $cur == --* ]]; then
    mapfile -t COMPREPLY < <(compgen -W "$long_flags" -- "$cur")
  elif [[ $cur == -* ]]; then
    mapfile -t COMPREPLY < <(compgen -W "$flags" -- "$cur")
  elif [[ $cur == .* && $cur != */* ]]; then
    local all="$builtin_types$custom_types" opts="." w
    for w in $all; do opts+=" .$w"; done
    mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
  elif [[ $cur == +* ]]; then
    COMPREPLY=()
  else
    _ktx_visible_dirs "$cur"
  fi
}

complete -F _ktx_completions ktx


