# ale.zsh-theme

# You can set your computer name in the ~/.box-name file if you want.

# Borrowing shamelessly from these zsh themes:
#	bira
#	robbyrussell
#	fino
#	agnoster
#	sorin
# Also borrowing from http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/

prompt_char() {
	git branch >/dev/null 2>/dev/null && echo "±" && return
	echo '○'
}

prompt_ale_host() {
	local name=""
    local host="$HOST"
	if [ -f ~/.box-name ]; then
		name=$(cat ~/.box-name)
	elif [[ "$SSH_CONNECTION" != "" ]]; then
		name="%m"
	fi
	if [[ "$name" != "" ]]; then
		echo " %F{white}at%f %F{blue}${name}%f"
	fi
}

prompt_virtualenv() {
	if [ -n "$VIRTUAL_ENV" ]; then
		if [ -f "$VIRTUAL_ENV/__name__" ]; then
			local name=`cat $VIRTUAL_ENV/__name__`
		elif [ `basename $VIRTUAL_ENV` = "__" ]; then
			local name=$(basename $(dirname $VIRTUAL_ENV))
		else
			local name=$(basename $VIRTUAL_ENV)
		fi
		echo "%F{red}$name%F{white}"
	fi
}

prompt_python() {
   version=$(python -c "import platform; print(platform.python_version())")
   icon=""
   echo "%F{yellow}$icon $version%F{white}"
}

prompt_ruby() {
	if (( $+commands[rvm-prompt] )); then
		version="$(rvm-prompt)"
	elif (( $+commands[rbenv] )); then
		version="$(rbenv version-name)"
	fi

	if [[ $version && $version != 'system' ]]; then
		echo "%F{red}$version%F{white}"
	fi
}

prompt_nodenv() {
	if [[ -n "$NODENV_VERSION" ]]; then
		echo "$NODENV_VERSION"
	elif [ $commands[nodenv] ]; then
		local nodenv_version_name="$(nodenv version-name)"
		local nodenv_global="$(nodenv global)"
		if [[ "${nodenv_version_name}" != "${nodenv_global}" ]]; then
			local name="$nodenv_version_name"
			echo "%F{red}$name%F{white}"
		fi
	fi
}

prompt_git_tag() {
    latest=$(git describe --abbrev=0 2> /dev/null)
    icon=""
    if [[ -n "$latest" ]]; then
        echo "%F{blue}$icon $latest %f"
    else
        echo ""
    fi
}

prompt_envs() {
	pyversion=($(prompt_python))
	local envs=()
	envs+=($(prompt_virtualenv))
	envs+=($(prompt_nodenv))
	
    echo " %F{white}using $pyversion%f ${(j., .)envs}%f"
}


prompt_git() {
    bold=$(tput bold)
    normal=$(tput sgr0)
	local ref
    local tag
	is_dirty() {
		test -n "$(git status --porcelain --ignore-submodules)"
	}
	ref="$vcs_info_msg_0_"
	if [[ -n "$ref" ]]; then
        tag=($(prompt_git_tag))
		ref="${tag}%F{white}on%f ${ref}"
		if $(is_dirty); then
			ref="${ref}%F{red}${bold}X${normal}"
		else
			ref="${ref}%F{green}${bold}✓${normal}"
		fi
		echo " $ref%f"
	fi
}

prompt_ale_precmd() {
	vcs_info
	_prompt_ale_pwd=$(prompt-pwd)

	PROMPT="%f╭─%F{green}%n%f$(prompt_ale_host) %F{white}in%f %B%F{yellow}${_prompt_ale_pwd}%b%f$(prompt_git)%b$(prompt_envs)
%f╰─$(prompt_char) "
	RPROMPT="%(?..%F{red}%? ↵%f)"
}

prompt_ale_setup() {
	autoload -Uz add-zsh-hook
	autoload -Uz vcs_info

	setopt prompt_subst

	add-zsh-hook precmd prompt_ale_precmd

	zstyle ':vcs_info:*' enable git
	zstyle ':vcs_info:*' check-for-changes false
	zstyle ':vcs_info:git*' formats '%b'
	zstyle ':vcs_info:git*' actionformats '%b (%a)'
}

prompt_ale_setup "$@"
