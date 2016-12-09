
fs() {
  local session

  session=$(tmux list-sessions -F "#{session_name}" | \
      fzf --query="$1" --select-1 --exit-0)

  if [ ! -z "$session" ]; then
      if [ ! -z "$TMUX" ]; then
          tmux switch-client -t "$session"
      else
          tmux attach -t "$session"
      fi
  fi
}

fto() {
  local panes current_window current_pane target target_pwd
  panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
  current_pane=$(tmux display-message -p '#I:#P')
  current_window=$(tmux display-message -p '#I')
  
  target=$(echo "$panes" | grep $current_window":" | grep -v "$current_pane")
  target_pwd=$(echo $target | awk '{print$3}')

  cd $target_pwd
}


# ftpane - switch pane (@george-b)
ftpane() {
  local panes current_window current_pane target target_window target_pane
  panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
  current_pane=$(tmux display-message -p '#I:#P')
  current_window=$(tmux display-message -p '#I')

  target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

  target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
  target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

  if [[ $current_window -eq $target_window ]]; then
      tmux select-pane -t ${target_window}.${target_pane}
  else
      tmux select-pane -t ${target_window}.${target_pane} &&
          tmux select-window -t $target_window
  fi
}

# bind-key 0 run "tmux split-window -l 12 'bash -ci ftpane'"
