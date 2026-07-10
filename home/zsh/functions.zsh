claude_wsp() {
  local project_dir="$HOME/.claude/projects/${PWD//\//-}"
  local sessions=("$project_dir"/*.jsonl(Nom))

  if (( $#sessions )); then
    local session_id="${${sessions[1]##*/}%.jsonl}"
    claude --resume "$session_id"
  else
    claude
  fi
}

nsxiv() {
  if (( $# == 0 )); then
    command nsxiv
    return
  fi

  local -a flags files
  local a f
  for a in "$@"; do
    if [[ "$a" == -* ]]; then
      flags+=("$a")
    elif [[ -d "$a" ]]; then
      for f in "$a"/*(.N); do files+=("$f"); done
    elif [[ -e "$a" ]]; then
      files+=("$a")
    fi
  done

  local has_raw=0
  for f in "${files[@]}"; do
    case "${f:l}" in
      *.cr2|*.cr3|*.arw|*.nef|*.dng|*.orf|*.rw2|*.raf) has_raw=1; break ;;
    esac
  done
  if (( ! has_raw )); then
    command nsxiv "$@"
    return
  fi

  local tmpdir
  tmpdir=$(mktemp -d /tmp/nsxiv-raw.XXXXXX) || return 1
  local base
  for f in "${files[@]}"; do
    base="${f:t}"
    case "${base:l}" in
      *.cr2|*.cr3|*.arw|*.nef|*.dng|*.orf|*.rw2|*.raf)
        local subdir
        subdir=$(mktemp -d "$tmpdir/raw.XXXXXX") || continue
        ln -sf "${f:A}" "$subdir/$base"
        if (cd "$subdir" && exiv2 -ep "$base" >/dev/null 2>&1); then
          local largest="" largest_size=0 pv s
          for pv in "$subdir"/*-preview*.jpg(N); do
            s=$(stat -c%s "$pv")
            if (( s > largest_size )); then
              largest_size=$s
              largest=$pv
            fi
          done
          if [[ -n "$largest" ]]; then
            mv "$largest" "$tmpdir/${base:r}.jpg"
          else
            echo "nsxiv: no jpg preview in $f" >&2
          fi
        else
          echo "nsxiv: no embedded preview in $f" >&2
        fi
        rm -rf "$subdir"
        ;;
      *)
        ln -s "${f:A}" "$tmpdir/$base"
        ;;
    esac
  done

  {
    command nsxiv "${flags[@]}" "$tmpdir"
  } always {
    rm -rf "$tmpdir"
  }
}

nixhelp() {
  export NIXPKGS_ALLOW_UNFREE=1

  local cmd="$1"
  local repo="$HOME/workspace/nixos"
  local file="$repo/modules/desktop.nix"
  local marker="]; # @end-system-packages"

  case "$cmd" in
    search)
      nix search nixpkgs "${@:2}"
      ;;
    try)
      nix shell --impure ${(@)argv[2,-1]/#/nixpkgs#}
      ;;
    update)
      echo "Give me sudo please, before I do anything"
      sudo echo "Thanks" || return 1

      local run_id
      run_id=$(date +%Y%m%d-%H%M%S)

      # Archive any leftover home-manager backups so HM can lay down fresh ones this run.
      local backup_archive="$HOME/.nixhelp-backups/${run_id}"
      local stale_backups
      stale_backups=$(find "$HOME" -xdev -type f -name '*.hm-bak' -not -path "$HOME/.nixhelp-backups/*" 2>/dev/null)
      if [[ -n "$stale_backups" ]]; then
        local count=$(echo "$stale_backups" | wc -l)
        echo "==> Archiving ${count} stale home-manager backup(s) to ${backup_archive}/"
        local f rel
        while IFS= read -r f; do
          rel="${f#$HOME/}"
          mkdir -p "${backup_archive}/$(dirname "$rel")"
          mv "$f" "${backup_archive}/${rel}"
        done <<< "$stale_backups"
      fi

      # Build strictly from origin/main in a detached-HEAD worktree; the main
      # repo is never touched, so local work (committed or not) is preserved.
      git -C "$repo" fetch origin main || return 1
      local origin_main_sha
      origin_main_sha=$(git -C "$repo" rev-parse origin/main) || return 1

      local worktree="/tmp/nixos-update-${run_id}"
      git -C "$repo" worktree remove --force "$worktree" 2>/dev/null || true
      git -C "$repo" worktree add --no-checkout --detach "$worktree" "$origin_main_sha" || return 1
      # git-crypt resolves its key via $(git rev-parse --git-dir), which in a
      # linked worktree is .git/worktrees/<name>/ — not the common .git/.
      # Symlink the git-crypt dir before checkout so the smudge filter works.
      ln -sf ../../git-crypt "$repo/.git/worktrees/${worktree##*/}/git-crypt"
      git -C "$worktree" checkout || return 1

      local update_ok=0
      {
        sudo nixos-rebuild switch --flake "path:$worktree#$(hostname)" || return 1
        update_ok=1
      } always {
        git -C "$repo" worktree remove --force "$worktree"
      }

      if (( update_ok )); then
        echo "==> Rebooting..."
        sudo systemctl reboot
      fi
      ;;
    test)
      local do_reboot=0 target=
      for arg in "${@:2}"; do
        if [[ "$arg" == "--reboot" ]]; then
          do_reboot=1
        else
          target="$arg"
        fi
      done
      if [[ -z "$target" ]]; then
        echo "Usage: nixhelp test [--reboot] <PR-<number>|[origin/]<branch>>"
        return 1
      fi
      local worktree="/tmp/nixos-test-${target//\//-}"
      local commit

      if [[ "$target" == PR-* ]]; then
        git -C "$repo" fetch origin "refs/pull/${target#PR-}/head" || return 1
        commit=$(git -C "$repo" rev-parse FETCH_HEAD) || return 1
      elif [[ "$target" == origin/* ]]; then
        git -C "$repo" fetch origin "${target#origin/}" || return 1
        commit=$(git -C "$repo" rev-parse "$target") || return 1
      else
        commit=$(git -C "$repo" rev-parse "$target") || return 1
      fi

      local rebuild_ok=0
      git -C "$repo" worktree remove --force "$worktree" 2>/dev/null || true
      git -C "$repo" worktree add "$worktree" "$commit" || return 1
      {
        if (( do_reboot )); then
          sudo nixos-rebuild boot --flake "path:$worktree#$(hostname)" && rebuild_ok=1
        else
          sudo nixos-rebuild test --flake "path:$worktree#$(hostname)"
        fi
      } always {
        git -C "$repo" worktree remove --force "$worktree"
      }
      if (( do_reboot && rebuild_ok )); then
        sudo systemctl reboot
      fi
      ;;
    rollback)
      local gen_count latest_gen
      gen_count=$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system | wc -l)
      if (( gen_count < 2 )); then
        echo "nixhelp rollback: only one generation exists, nothing to roll back to."
        return 1
      fi
      latest_gen=$(sudo nix-env --list-generations -p /nix/var/nix/profiles/system \
        | tail -1 | awk '{print $1}')
      echo "==> Rolling back from generation ${latest_gen}..."
      sudo nixos-rebuild switch --rollback || return 1
      sudo nix-env --delete-generations "$latest_gen" -p /nix/var/nix/profiles/system
      echo "==> Removed generation ${latest_gen}."
      ;;
    *)
      echo "Usage: nixhelp <search|try|update|test|rollback> [pkg]"
      ;;
  esac
}

_nixhelp() {
  local repo="$HOME/workspace/nixos"

  if (( CURRENT == 2 )); then
    local -a cmds=(
      'search:nix search'
      'try:nix shell'
      'update:rebuild from origin/main'
      'test:test a branch or PR'
      'rollback:roll back one generation'
    )
    _describe 'nixhelp command' cmds
    return
  fi

  case "${words[2]}" in
    test)
      local -a flags locals remotes prs
      flags=('--reboot:reboot after test')
      locals=(${(f)"$(git -C "$repo" branch --format='%(refname:short)' 2>/dev/null)"})
      remotes=(${(f)"$(git -C "$repo" branch -r --format='%(refname:short)' 2>/dev/null | grep -v '/HEAD$')"})
      prs=(${(f)"$(cd "$repo" 2>/dev/null && gh pr list --state open --json number,title -q '.[]|"PR-\(.number):\(.title)"' 2>/dev/null)"})

      _describe -t flags   'flag'          flags
      _describe -t locals  'local branch'  locals
      _describe -t remotes 'remote branch' remotes
      (( $#prs )) && _describe -t prs 'open PR' prs
      ;;
  esac
}
compdef _nixhelp nixhelp

diesoon() {
  local battery_pct mins

  if [[ $# -eq 2 ]]; then
    [[ ! "$1" =~ ^[0-9]+$ || ! "$2" =~ ^[0-9]+$ ]] && { echo "Usage: diesoon [battery_pct] <minutes>"; return 1; }
    battery_pct="$1"
    mins="$2"
  elif [[ $# -eq 1 ]]; then
    [[ ! "$1" =~ ^[0-9]+$ ]] && { echo "Usage: diesoon <minutes>"; return 1; }
    mins="$1"
  else
    echo "Usage: diesoon [battery_pct] <minutes>"
    return 1
  fi

  local bat_caps=(/sys/class/power_supply/BAT*/capacity(N))
  local bat_stats=(/sys/class/power_supply/BAT*/status(N))
  local bat_cap=$bat_caps[1] bat_status=$bat_stats[1]
  local bat_dir="${bat_cap:h}"

  local start=$(date +%s)
  local deadline=$(( start + mins * 60 ))

  printf 'diesoon: now %s, shutdown at %s (in %dm)\n' \
    "$(date -d @$start +%H:%M)" "$(date -d @$deadline +%H:%M)" "$mins"

  local last_print=$start
  local print_interval=300
  local poll_interval=30

  while true; do
    local now=$(date +%s)

    if (( now >= deadline )); then
      echo "diesoon: time limit reached, powering off..."
      systemctl poweroff; return
    fi

    if [[ -n "$battery_pct" ]]; then
      local pct=$(cat "$bat_cap" 2>/dev/null)
      local st=$(cat "$bat_status" 2>/dev/null)
      if [[ "$st" != "Charging" && -n "$pct" && "$pct" -le "$battery_pct" ]]; then
        echo "diesoon: battery at ${pct}%, powering off..."
        systemctl poweroff; return
      fi
    fi

    if (( now - last_print >= print_interval )); then
      last_print=$now
      local hard_remain=$(( (deadline - now + 59) / 60 ))
      local eta_msg=""

      if [[ -n "$battery_pct" ]]; then
        local st=$(cat "$bat_status" 2>/dev/null)
        if [[ "$st" != "Charging" ]]; then
          local now_key full_key rate_key
          if [[ -r "$bat_dir/energy_now" ]]; then
            now_key=energy_now; full_key=energy_full; rate_key=power_now
          elif [[ -r "$bat_dir/charge_now" ]]; then
            now_key=charge_now; full_key=charge_full; rate_key=current_now
          fi
          if [[ -n "$now_key" ]]; then
            local e_now=$(cat "$bat_dir/$now_key" 2>/dev/null)
            local e_full=$(cat "$bat_dir/$full_key" 2>/dev/null)
            local e_rate=$(cat "$bat_dir/$rate_key" 2>/dev/null)
            if [[ -n "$e_now" && -n "$e_full" && -n "$e_rate" ]] && (( e_rate > 0 )); then
              local target=$(( e_full * battery_pct / 100 ))
              local delta=$(( e_now - target ))
              if (( delta > 0 )); then
                local eta_min=$(( delta * 3600 / e_rate / 60 ))
                eta_msg=", battery limit in ~${eta_min}m"
              fi
            fi
          fi
        fi
      fi

      echo "diesoon: hard limit in ${hard_remain}m${eta_msg}"
    fi

    sleep $poll_interval
  done
}
