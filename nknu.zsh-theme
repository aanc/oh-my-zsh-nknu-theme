# '#' for root prompt, '$' for regular user
[[ $(whoami) == "root" ]] && local prompt_type='#' || local prompt_type='$'

# Red status (for red prompt if previous command exited with error)
local ret_status="%(?:%{$fg_bold[cyan]%}${prompt_type}:%{$fg_bold[red]%}${prompt_type}%s)"

# Git
nknu_git_status () {
	local _s=
	local _nknu_git_status=
	local _stage_status=
	local _ahead_behind=

	local _char_ahead="-ahead- "
	local _char_behind="-behind- "
	local _char_diverged="-diverged- "
	local _char_status="● "

	# Git status to retrieve infos
	_s=$(LANG=C command git status --porcelain -b 2>/dev/null)

	# Branch name
	local _branch=$(echo "$_s" | head -1 | grep '^## ' 2>/dev/null | sed "s/\.\.\./ /" | cut -d' ' -f2) 

	# Stop here if no branch name (to be improved for detached state)
	[[ -z $_branch ]] && return 0

	# Green dot if staged
	[[ -n $(echo "$_s" | grep '^[AMRD]. ' 2> /dev/null) ]] && _stage_status="%{$fg[green]%}$_char_status%{$reset_color%}"

	# Yellow dot if untracked
	[[ -n $(echo "$_s" | grep '^?? ' 2> /dev/null) ]] && _stage_status="${_stage_status}%{$fg[yellow]%}$_char_status%{$reset_color%}"

	# Red dot if unstaged
	[[ -n $(echo "$_s" | grep '^.[MTD] ' 2> /dev/null) ]] && _stage_status="${_stage_status}%{$fg[red]%}$_char_status%{$reset_color%}"

	# if ahead
	local ahead=
	[[ -n $(echo "$_s" | grep '^## .*ahead' 2> /dev/null) ]] && _ahead_behind="${_ahead_behind}%{$fg[green]%}${_char_ahead}%{$reset_color%}" && ahead=1

	# if behind
	local behind=
	[[ -n $(echo "$_s" | grep '^## .*behind' 2> /dev/null) ]] && _ahead_behind="${_ahead_behind}%{$fg[red]%}${_char_behind}%{$reset_color%}" && behind=1
	
	# ahead and behind == diverged !
	[[ -n $ahead && -n $behind ]] && _ahead_behind="%{$fg[yellow]%}${_char_diverged}%{$reset_color%}"

	[[ -z $_stage_status ]] && _stage_status="%{$fg[cyan]%}$_char_status%{$reset_color%}"

	# Ok, print all that stuff !
	echo "%{$fg_bold[white]%}git:%{$reset_color%}${_branch} ${_stage_status} ${_ahead_behind}"
}

nknu_git_status='$(nknu_git_status)'

# Prompt
PROMPT="
%{$fg[cyan]%}\
%{$fg_bold[white]%}%n%{$reset_color%}%{$fg[cyan]%}@%{$fg[green]%}%m%{$reset_color%} \
${nknu_git_status}\
%{$fg[white]%}[%*]
%{$fg[cyan]%}\
%{$fg[white]%}%~%{$reset_color%}%{$fg[cyan]%} ${ret_status}%{$reset_color%} "

PS2=$' %{$fg[cyan]%}|>%{$reset_color%} '


