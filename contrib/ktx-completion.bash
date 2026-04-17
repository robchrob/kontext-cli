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
    [[ -d ${COMP_WORDS[i]} ]] && dir=${COMP_WORDS[i]}
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
  elif [[ $cur == .* ]]; then
    local all="$builtin_types$custom_types" opts="" w
    for w in $all; do opts+=" .$w"; done
    mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
  elif [[ $cur == +* || $cur == -* ]]; then
    COMPREPLY=()
  else
    mapfile -t COMPREPLY < <(compgen -d -- "$cur")
  fi
}
complete -F _ktx_completions ktx
