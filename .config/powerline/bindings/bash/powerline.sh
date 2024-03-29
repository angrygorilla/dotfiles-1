_powerline_init_tmux_support() {
	if test -n "$TMUX" && tmux refresh -S &>/dev/null ; then
		# TMUX variable may be unset to create new tmux session inside this one
		_POWERLINE_TMUX="$TMUX"

		_powerline_tmux_setenv() {
			TMUX="$_POWERLINE_TMUX" tmux setenv -g TMUX_"$1"_`tmux display -p "#D" | tr -d %` "$2"
			TMUX="$_POWERLINE_TMUX" tmux refresh -S
		}

		_powerline_tmux_set_pwd() {
			if test "x$_POWERLINE_SAVED_PWD" != "x$PWD" ; then
				_POWERLINE_SAVED_PWD="$PWD"
				_powerline_tmux_setenv PWD "$PWD"
			fi
		}

		_powerline_tmux_set_columns() {
			_powerline_tmux_setenv COLUMNS "$COLUMNS"
		}

		trap "_powerline_tmux_set_columns" SIGWINCH
		_powerline_tmux_set_columns
	else
		_powerline_tmux_set_pwd() {
			return 0
		}
	fi
	test "x$PROMPT_COMMAND" != "x${PROMPT_COMMAND%_powerline_tmux_set_pwd*}" ||
		export PROMPT_COMMAND=$'_powerline_tmux_set_pwd\n'"${PROMPT_COMMAND}"
}

_run_powerline() {
	# Arguments: side, last_exit_code, jobnum
	$POWERLINE_COMMAND shell $1 -w $COLUMNS -r bash_prompt --last_exit_code=$2 --jobnum=$3
}

_powerline_prompt() {
	local last_exit_code=$?
	local jobnum="$(jobs -p|wc -l)"
	PS1="$(_run_powerline aboveleft $last_exit_code $jobnum)"
	return $last_exit_code
}

_powerline_setup_prompt() {
	if test -z "${POWERLINE_COMMAND}" ; then
		if which powerline-client &>/dev/null ; then
			export POWERLINE_COMMAND=powerline-client
		elif which powerline &>/dev/null ; then
			export POWERLINE_COMMAND=powerline
		else
			# `$0` is set to `-bash` when using SSH so that won't work
			export POWERLINE_COMMAND="$(dirname "$BASH_SOURCE")/../../../scripts/powerline"
		fi
	fi
	test "x$PROMPT_COMMAND" != "x${PROMPT_COMMAND%_powerline_prompt*}" ||
		export PROMPT_COMMAND=$'_powerline_prompt\n'"${PROMPT_COMMAND}"
}

if test -z "$POWERLINE_NO_BASH_PROMPT$POWERLINE_NO_SHELL_PROMPT" ; then
	_powerline_setup_prompt
fi
if test -z "$POWERLINE_NO_BASH_TMUX_SUPPORT$POWERLINE_NO_SHELL_TMUX_SUPPORT" ; then
	_powerline_init_tmux_support
fi
