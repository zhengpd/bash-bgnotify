# bash-bgnotify

Cross-platform background notifications for long running commands! Supports OSX and Ubuntu linux.

Forked from Tim O'Brien's awesome [zsh-background-notify](https://github.com/t413/zsh-background-notify) and slightly modified for Bash.

## How to use!

1. Install Bash-Preexec following the instructions on <https://github.com/rcaloras/bash-preexec#install>
2. Clone the repository:
  * `git clone https://github.com/zhengpd/bash-bgnotify.git ~/.bash-bgnotify`
3. And add one line your `.bashrc`:
  * `source $HOME/.bash-bgnotify/bgnotify.plugin.bash`
4. Done!

## Requirements:

- On OS X you'll need [terminal-notifer](https://github.com/alloy/terminal-notifier)
  * `brew install terminal-notifier` (or `gem install terminal-notifier`)
- On ubuntu you're already all set!
- On windows you can use [notifu](http://www.paralint.com/projects/notifu/) or the Cygwin Ports `libnotify` package

## Configuration

One can configure a few things:

- `bgnotify_threshold` sets the notification threshold time (default 6 seconds)
- `function notify_formatted` lets you change the notification

Use these by adding a function definition before the your call to source. Example:

~~~ sh
bgnotify_threshold=4  ## set your own notification threshold

function notify_formatted {
  ## $1=exit_status, $2=command, $3=elapsed_time
  [ $1 -eq 0 ] && title="Holy Smokes Batman!" || title="Holy Graf Zeppelin!"
  bgnotify "$title -- after $3 s" "$2";
}

source $HOME/.bash-bgnotify/bgnotify.plugin.bash
~~~


## How it works

[Bash-Preexec](https://github.com/rcaloras/bash-preexec) provides two hook functions for Bash in the style of Zsh: `preexec` that runs before executing a command and `precmd` that runs just before re-prompting. Timing the difference between them gives you execution time!

To check if you're in the background we can use xprop to find the NET_ACTIVE_WINDOW in ubuntu and osascript to run a simple apple script to get the same thing (although slower).
