# oh-my-zsh emojeer Theme

### Customization
# colors{{{ in terminal use `spectrum_bls` check xterm-256 color palette
_USER_COLOR='007'
_HOST_COLOR='093'
_PATH_COLOR='003'
_BIO_COLOR='007'
_UNDERLINE_COLORS=()
# }}}

# emojis{{{
_USER_ICON='👶'
_HOST_ICON='🖥'
_PATH_ICON='📂'

_TIME_ICON='⌚'
_CALENDAR_ICON='📅'
_BATTERY_ICON='🔋'

_OPEN_CHAR='△'
_CLOSE_CHAR='▼'
# }}}

_BIO='（￣▽￣）～■□～（￣▽￣）'

# Git{{{ default: ( ±master ▾● )
ZSH_THEME_GIT_PROMPT_PREFIX="( %{$fg_bold[green]%}±%{$reset_color%}%{$fg_bold[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} )"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"
# }}}

# NVM{{
ZSH_THEME_NVM_PROMPT_PREFIX="%B⬡%b "
ZSH_THEME_NVM_PROMPT_SUFFIX=""
# }}}


### Functions/Utils
my_precmd () {
   _1LEFT="$_PATH_ICON  %{$FG[$_PATH_COLOR]%} $_OPEN_CHAR %~ $_CLOSE_CHAR%{$reset_color%} $(nvm_prompt_info) $(git_prompt)"
   _1RIGHT=" $_TIME_ICON %t $_CALENDAR_ICON %W $_BATTERY_ICON $(battery_percentage)% "
  _1SPACES=$(get_space $_1LEFT$_1RIGHT)

  # draw an underline to seperate each command
  RANDOM=$RANDOM # change the pseudo-random `RANDOM` value for subshell, reference: http://www.zsh.org/mla/workers/2015/msg00553.html
  _UNDERLINE_COLOR=$(get_random_color $_UNDERLINE_COLORS)
  print -rP $'%{$FG[$_UNDERLINE_COLOR]%}%U${(r:$COLUMNS:: :)}%u'

  print
  print -rP $_USER
  print -rP "$_1LEFT$_1SPACES$_1RIGHT"
  print
}
git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}
git_status() {
  _STATUS=""

  # check status of files
  _INDEX=$(command git status --porcelain 2> /dev/null)
  if [[ -n "$_INDEX" ]]; then
    if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$_INDEX" | command grep -q '^UU '); then
      _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
  else
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  # check status of local repository
  _INDEX=$(command git status --porcelain -b 2> /dev/null)
  if $(echo "$_INDEX" | command grep -q '^## .*ahead'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*behind'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | command grep -q '^## .*diverged'); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  if $(command git rev-parse --verify refs/stash &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi

  echo $_STATUS
}
git_prompt () {
  local _branch=$(git_branch)
  local _status=$(git_status)
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="$ZSH_THEME_GIT_PROMPT_PREFIX$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result $_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}
get_random_color() {
  args_len=$#
  # default case
  if [ $args_len -eq 0 ]
  then
    args_len=256
    echo $[${RANDOM}%$args_len]
    exit 0
  fi
  # customized case
  (( random_index = $[${RANDOM}%$args_len] + 1 ))
  echo $@[$random_index]
}
battery_percentage() {
  ioreg -n AppleSmartBattery -r |
  awk '$1~/Capacity/{c[$1]=$3} END{OFMT="%.2f%%"
  max=c["\"MaxCapacity\""]
  print (max>0? 100*c["\"CurrentCapacity\""]/max: "?")}'
}
get_space () {
  local STR=$1$2
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=""
  (( LENGTH = ${COLUMNS} - $LENGTH - 1))

  for i in {0..$LENGTH}
    do
      SPACES="$SPACES "
    done

  echo $SPACES
}

### Prompt
_NEWLINE=$'\n'

_USER="$_USER_ICON  %{$FG[$_USER_COLOR]%} $_OPEN_CHAR lxynox $_CLOSE_CHAR
$_HOST_ICON  %{$FG[$_HOST_COLOR]%} $_OPEN_CHAR GemIsland $_CLOSE_CHAR"

if [[ $EUID -eq 0 ]]; then
  _LIBERTY="%{$fg[red]%}#"
else
  _LIBERTY="%{$fg[green]%}$"
fi
_LIBERTY="$_LIBERTY%{$reset_color%}"
PROMPT='☛ $_LIBERTY '
RPROMPT='%{$FG[$_BIO_COLOR]%} $_BIO'

autoload -U add-zsh-hook
add-zsh-hook precmd my_precmd
