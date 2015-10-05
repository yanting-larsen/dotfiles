function fish_user_key_bindings
	set -g fish_key_bindings fish_vi_key_bindings
	fish_default_key_bindings -M insert

	if type -q fzf_key_bindings
		fzf_key_bindings
	end

	#
	# Normal mode
	#
	bind \n '__commandline_execute'
	bind e forward-word backward-char
	bind E forward-bigword backward-char

	bind \ei __commandline_edit
	bind \cl '__commandline_clear_prompt'

	#
	# Insert mode
	#
	bind -M insert --key btab complete-and-search

	bind -M insert \cl '__commandline_clear_prompt'
	bind -M insert \el '__fish_list_current_token; __commandline_reload_prompt'
	bind -M insert \e'<' 'prevd; __commandline_reload_prompt'
	bind -M insert \e'>' 'nextd; __commandline_reload_prompt'

	# Execute
	bind -M insert \n '__commandline_execute'
	bind -M insert \e\n '__commandline_execute_and_keep_line'
	bind -M insert \e',' 'commandline -f execute history-search-backward'
	bind -M insert \em 'commandline -f execute accept-autosuggestion'
	bind -M insert \ez 'fg >/dev/null ^/dev/null'

	# Insert last argument of previous command
	bind -M insert \e. history-token-search-backward

	# Commandline
	bind -M insert \cx __commandline_eval_token
	bind -M insert \er __commandline_sudo_toggle

	# Stash/pop
	bind -M insert \es __commandline_stash
	bind -M insert \eS __commandline_pop

	bind -M insert \cv __commandline_paste
end

function __commandline_execute
	set value (commandline)
	if test -n "$value"
		commandline -f execute
	else
		echo
	end
end

function __commandline_reload_prompt
	set_color normal
	fish_prompt
	commandline -f repaint
end

function __commandline_clear_prompt
	set -ge __prompt_context_current
	clear
	__commandline_reload_prompt
end

function __commandline_insert_previous_token
	set -l tokens (commandline -po)
	test $tokens[1]; or return

	set -l previous_token $tokens[-1]

	if test -n (commandline -pt)
		set previous_token " $previous_token"
	end

	commandline -i $previous_token
end

function __commandline_eval_token
	set -l token (commandline -t)

	if test -n "$token"
		set -l value (eval string escape $token | string join ' ')
		if test -n "$value" -a "$value" != ' '
			commandline -t $value
			commandline -f backward-char
		end
	end
end

function __commandline_edit --description 'Input command in external editor'
	set -l f (mktemp /tmp/fish.cmd.XXXXXXXX)
	if test -n "$f"
		set -l p (commandline -C)
		commandline -b > $f
		eval $EDITOR $f
		commandline -r (more $f)
		commandline -C $p
		command rm $f
	end
end

function __commandline_sudo_toggle
	set -l pos (commandline -C)
	set -l cmd (commandline -b)

	if string match -q 'sudo *' $cmd
		set pos (expr $pos - 5)
		commandline (string replace 'sudo ' '' $cmd)
	else
		commandline -C 0
		commandline -i 'sudo '
		set pos (expr $pos + 5)
	end

	commandline -C $pos
end

function __commandline_stash -d 'Stash current command line'
	set -g __stash_command_position (commandline -C)
	set -g __stash_command (commandline -b)
	commandline -r ''
end

function __commandline_pop -d 'Pop last stashed command line'
	if not set -q __stash_command
		return
	end

	commandline -r $__stash_command

	if set -q __stash_command_position
		commandline -C $__stash_command_position
	end

	set -e __stash_command
	set -e __stash_command_position
end

function __commandline_toggle -d 'Stash current commandline if not empty, otherwise pop last stashed commandline'
	set -l cmd (commandline -b)

	if test "$cmd"
		__commandline_stash
	else
		__commandline_pop
	end
end

function __commandline_paste
	if type -fq pbpaste
		commandline -i (pbpaste)
		return
	end

	if not set -qg DISPLAY
		return
	end

	if type -fq xsel
		commandline -i (xsel)
	else if type -fq xclip
		commandline -i (xclip -o)
	end
end

function __commandline_sudo_execute
	commandline -C 0
	commandline -i 'sudo '
	commandline -f execute
end

function __commandline_execute_and_keep_line
	set -l pos (commandline -C)
	set -l cmd (commandline -b)

	commandline -f execute

	while true
		set funcname __fish_restore_line_(random);
		if not functions $funcname >/dev/null ^/dev/null
			break;
		end
	end

	function $funcname -V funcname -V pos -V cmd -j %self
		commandline -r "$cmd"
		commandline -C $pos
		functions -e $funcname
	end
end
