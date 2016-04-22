#!/usr/bin/env bash

## setup ##

[[ $- != *i* ]] && return # interactive only!

(( ${bgnotify_threshold} )) || bgnotify_threshold=3 #default 3 seconds


## definitions ##

if ! type -t bgnotify_formatted 1>/dev/null; then ## allow custom function override
  function bgnotify_formatted { ## args: (exit_status, command, elapsed_seconds)
    elapsed="$(( $3 % 60 ))s"
    (( $3 >= 60 )) && elapsed="$((( $3 % 3600) / 60 ))m $elapsed"
    (( $3 >= 3600 )) && elapsed="$(( $3 / 3600 ))h $elapsed"
    [ $1 -eq 0 ] && bgnotify "#win (took $elapsed)" "$2" || bgnotify "#fail (took $elapsed)" "$2"
  }
fi

get_timestamp() {
  date +%s
}

currentWindowId () {
  if hash osascript 2>/dev/null; then #osx
    osascript -e 'tell application (path to frontmost application as text) to id of front window' 2> /dev/null || echo "0"
  elif (hash notify-send 2>/dev/null || hash kdialog 2>/dev/null); then #ubuntu!
    xprop -root 2> /dev/null | awk '/NET_ACTIVE_WINDOW/{print $5;exit} END{exit !$5}' || echo "0"
  else
    echo $(get_timestamp) # fallback for windows
  fi
}

bgnotify () { ## args: (title, subtitle)
  tput bel # ring the bell

  if hash terminal-notifier 2>/dev/null; then #osx
    [[ "$TERM_PROGRAM" == 'iTerm.app' ]] && term_id='com.googlecode.iterm2';
    [[ "$TERM_PROGRAM" == 'Apple_Terminal' ]] && term_id='com.apple.terminal';
    ## now call terminal-notifier, (hopefully with $term_id!)
    [ -z "$term_id" ] && terminal-notifier -message "$2" -title "$1" >/dev/null ||
    terminal-notifier -message "$2" -title "$1" -activate "$term_id" -sender "$term_id" >/dev/null
  elif hash growlnotify 2>/dev/null; then #osx growl
    growlnotify -m "$1" "$2"
  elif hash notify-send 2>/dev/null; then #ubuntu gnome!
    notify-send "$1" "$2"
  elif hash kdialog 2>/dev/null; then #ubuntu kde!
    kdialog  -title "$1" --passivepopup  "$2" 5
  elif hash notifu 2>/dev/null; then #cygwyn support!
    notifu /m "$2" /p "$1"
  fi
}


## Hooks ##

bgnotify_begin() {
  bgnotify_timestamp=$(get_timestamp)
  bgnotify_lastcmd="$1"
  bgnotify_windowid=$(currentWindowId)
}

bgnotify_end() {
  didexit=$?
  elapsed=$(( $(get_timestamp) - bgnotify_timestamp ))
  past_threshold=$(( elapsed >= bgnotify_threshold ))
  if (( bgnotify_timestamp > 0 )) && (( past_threshold )); then
    if [ $(currentWindowId) != "$bgnotify_windowid" ]; then
      bgnotify_formatted "$didexit" "$bgnotify_lastcmd" "$elapsed"
    fi
  fi
  bgnotify_timestamp=0 #reset it to 0!
}

## only enable if a local (non-ssh) connection
if [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
  preexec_functions+=(bgnotify_begin)
  precmd_functions+=(bgnotify_end)
fi
