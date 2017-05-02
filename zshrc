: ${DOTFILES_HOME:=~/dotfiles}
ZSH_CACHE="${XDG_CACHE_HOME:=$HOME/.cache}/zsh"
[ -d "$ZSH_CACHE" ] || mkdir -p "$ZSH_CACHE"

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

##############
# Completion #
##############

autoload -Uz compinit
compinit -D -d "$ZSH_CACHE/compdump"

# Hyphen and case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*'

# Highlight current menu element
zstyle ':completion:*:*:*:*:*' menu select

# Enable caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$ZSH_CACHE"

# Fancy kill completion menu                                   pid      user          comm     etime
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#) #([^ ]#) #([0-9:]#)*=0=0=0=00;36=0=0'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,etime -w -w"

# Menu completion colours matching ls
eval $(dircolors)
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

############
# Bindings #
############
bindkey -e # Emacs
bindkey '^r' history-incremental-search-backward
b() {
    [ -n "$1" ] && bindkey "$1" "$2"
}
b "${terminfo[kcuu1]}" up-line-or-search # Up
b "${terminfo[kcud1]}" down-line-or-search # Down
# TODO add ctrl-right|left mapping to forward|backward-word
b "${terminfo[kcbt]}" reverse-menu-complete # Shift-Tab
unfunction b

###########
# Aliases #
###########

source "$DOTFILES_HOME/zsh/zshmarks/init.zsh"
alias j=jump
wait_for() {
    local wait_pid
    if [[ $1 =~ ^[0-9]+$ ]] ; then
        if ps $1 > /dev/null ; then
            wait_pid=$1
        else
            print -- "PID given but process does not exist."
            return -1
        fi
    else
        # We only want one process, so let's get the newest and hope it's the
        # right one :)
        if ! wait_pid=$(pgrep -xn $1) ; then
            print -- "$1: process not found"
            return -1
        fi
    fi
    print "Waiting for PID $wait_pid."
    ps "$wait_pid"
    while ps $wait_pid > /dev/null ; do
        sleep 1
    done
}

ls() {
    if [[ $# = 1 ]]
    then
        if [[ -f "$1" ]]
        then
            less "$1"
        else
            "$(whence -p ls)" --color=auto "$1"
        fi
    else
        "$(whence -p ls)" --color=auto $*
    fi
}

closure() {
    nix-store -qR "$@" | xargs du -chd0 | sort -h
}

[[ -f "$DOTFILES_HOME/zsh/local" ]] && source "$DOTFILES_HOME/zsh/local"

###########
# Options #
###########

setopt AUTO_PUSHD PUSHD_IGNORE_DUPS CHASE_LINKS HIST_IGNORE_DUPS EXTENDED_HISTORY
unsetopt SHARE_HISTORY
unsetopt NOMATCH

zshaddhistory() {
    [[ $* =~ reboot ]] && return 1
    return 0
}

source "$DOTFILES_HOME/shell-common"
