set -g fish_greeting

if status is-interactive
	starship init fish | source
end

# List Directory
alias l='eza -lh  --icons=auto' # long list
alias ls='eza -1   --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree

# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
abbr mkdir 'mkdir -p'

# Add new line after each execution on the end of command/bottom
function postexec_newline --on-event fish_postexec
	# $argv holds the command that just finished
	if test "$argv[1]" != "clear"
		echo
	end
end

# Java sdkman shells
set SDKMAN_INIT false
function sdk
	if test "$SDKMAN_INIT" = false
		sdkinit
	else
		bass source $HOME/.sdkman/bin/sdkman-init.sh ';' sdk $argv
	end
end
function sdkinit
	set SDKMAN_INIT true
	bass source $HOME/.sdkman/bin/sdkman-init.sh ';' true
	echo "Initializing..."
	sdk current # Show the envs
end
