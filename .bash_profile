if [ -f ~/.bashrc ]; then
      . ~/.bashrc
fi

alias goog="cd /google/src/cloud/andycoenen"

# Typescript remote hostname
export REMOTE_TSSERVER_HOSTNAME=andycoenen.mtv.corp.google.com

# Mounting filesystem
export DESKTOP_HOSTNAME=andycoenen.mtv.corp.google.com
alias mount="/google/src/head/depot/google3/javascript/typescript/contrib/remote_tslib/mount.sh"

# Allow g4d tab completion
source /Library/GoogleCorpSupport/srcfs/shell_completion/enable_completion.sh

# bagpipe
export P4CONFIG=.p4config
export P4EDITOR=vi

# Global stuff
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH="$PATH:$(yarn global bin)"

# Homebrew stuff
export PATH=$HOME/homebrew/bin:$PATH
export LD_LIBRARY_PATH=$HOME/homebrew/lib:$LD_LIBRARY_PATH

export PS1="\[\033[32m\]\u:\[\033[33;1m\]\W\[\033[m\]\$ "

export EDITOR='code'

alias prof="code ~/.bash_profile"
alias reprof=". ~/.bash_profile"
alias auth="AUTH_HOST=$DESKTOP_HOSTNAME python ~/bin/auth_refresh-gtunnel.py"

gssh() {
  ssh andycoenen@andycoenen.mtv.corp.google.com -L ${1-5432}:localhost:${1-5432} -t bash -i
}

RO_MOUNTS=()

RW_MOUNTS=(
    /usr/local/google/home/$USER)


#Meta alias's
alias prof="atom ~/.bash_profile"
alias reprof=". ~/.bash_profile"
alias chrome="open -a Google\ Chrome"
alias chr="open -a Google\ Chrome"
alias de="cd ~/Desktop"
alias js="bundle exec jekyll serve --watch"
alias jb="bundle exec jekyll build"

#git alias
alias gb="git branch"
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gs="git status"
alias ga="git add"
alias gpo="git push origin"
alias gpu="git push upstream"
alias gco="git checkout"
alias gcp="git cherry-pick"
alias gpom="git push origin master"
alias grv="git remote -v"
alias gh="git hist"
alias gl="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"
alias glu="git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
alias git=hub
alias gbo="git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname) %(committerdate) %(authorname)' | sed 's/refs\/heads\///g'"
alias gacm="git add .; git commit -m"
alias grc="git rebase --continue"

unalias gd
function gd() {
    if [ -n "$1" ]
    then
        git diff --color "$1" | diff-so-fancy | less --tabs=4 -RFX
    else
        git diff --color | diff-so-fancy | less --tabs=4 -RFX
    fi
}

alias gp="git push"
alias gpl="git pull"
alias gplo="git pull origin"
alias gf="git fetch"

alias kan="killall node"
ka () {
  killall "$1"
}

#combine mkdir and cd
mkcd () {
  mkdir "$1"
  cd "$1"
}

#Run a python simple server
alias serve="python -m SimpleHTTPServer"


export PATH=$HOME/bin:$PATH

. $HOME/.bagpipe/setup.sh $HOME/.bagpipe andycoenen.mtv.corp.google.com
export PATH=$HOME/bin:$PATH # added by Anaconda2 2018.12 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$(CONDA_REPORT_ERRORS=false '/anaconda2/bin/conda' shell.bash hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    \eval "$__conda_setup"
else
    if [ -f "/anaconda2/etc/profile.d/conda.sh" ]; then
        . "/anaconda2/etc/profile.d/conda.sh"
        CONDA_CHANGEPS1=false conda activate base
    else
        \export PATH="/anaconda2/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda init <<<

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/andycoenen/google-cloud-sdk/path.bash.inc' ]; then . '/Users/andycoenen/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/andycoenen/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/andycoenen/google-cloud-sdk/completion.bash.inc'; fi





if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# show current directory in tab title
function tab_title {
  echo -n -e "\033]0;${PWD##*/}\007"
}
PROMPT_COMMAND="tab_title ; $PROMPT_COMMAND"

[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh  # This loads NVM

# Automatically add completion for all aliases to commands having completion functions
function alias_completion {
    local namespace="alias_completion"

    # parse function based completion definitions, where capture group 2 => function and 3 => trigger
    local compl_regex='complete( +[^ ]+)* -F ([^ ]+) ("[^"]+"|[^ ]+)'
    # parse alias definitions, where capture group 1 => trigger, 2 => command, 3 => command arguments
    local alias_regex="alias ([^=]+)='(\"[^\"]+\"|[^ ]+)(( +[^ ]+)*)'"

    # create array of function completion triggers, keeping multi-word triggers together
    eval "local completions=($(complete -p | sed -Ene "/$compl_regex/s//'\3'/p"))"
    (( ${#completions[@]} == 0 )) && return 0

    # create temporary file for wrapper functions and completions
    rm -f "/tmp/${namespace}-*.tmp" # preliminary cleanup
    local tmp_file; tmp_file="$(mktemp "/tmp/${namespace}-${RANDOM}XXX.tmp")" || return 1

    local completion_loader; completion_loader="$(complete -p -D 2>/dev/null | sed -Ene 's/.* -F ([^ ]*).*/\1/p')"

    # read in "<alias> '<aliased command>' '<command args>'" lines from defined aliases
    local line; while read line; do
        eval "local alias_tokens; alias_tokens=($line)" 2>/dev/null || continue # some alias arg patterns cause an eval parse error
        local alias_name="${alias_tokens[0]}" alias_cmd="${alias_tokens[1]}" alias_args="${alias_tokens[2]# }"

        # skip aliases to pipes, boolean control structures and other command lists
        # (leveraging that eval errs out if $alias_args contains unquoted shell metacharacters)
        eval "local alias_arg_words; alias_arg_words=($alias_args)" 2>/dev/null || continue
        # avoid expanding wildcards
        read -a alias_arg_words <<< "$alias_args"

        # skip alias if there is no completion function triggered by the aliased command
        if [[ ! " ${completions[*]} " =~ " $alias_cmd " ]]; then
            if [[ -n "$completion_loader" ]]; then
                # force loading of completions for the aliased command
                eval "$completion_loader $alias_cmd"
                # 124 means completion loader was successful
                [[ $? -eq 124 ]] || continue
                completions+=($alias_cmd)
            else
                continue
            fi
        fi
        local new_completion="$(complete -p "$alias_cmd")"

        # create a wrapper inserting the alias arguments if any
        if [[ -n $alias_args ]]; then
            local compl_func="${new_completion/#* -F /}"; compl_func="${compl_func%% *}"
            # avoid recursive call loops by ignoring our own functions
            if [[ "${compl_func#_$namespace::}" == $compl_func ]]; then
                local compl_wrapper="_${namespace}::${alias_name}"
                    echo "function $compl_wrapper {
                        (( COMP_CWORD += ${#alias_arg_words[@]} ))
                        COMP_WORDS=($alias_cmd $alias_args \${COMP_WORDS[@]:1})
                        (( COMP_POINT -= \${#COMP_LINE} ))
                        COMP_LINE=\${COMP_LINE/$alias_name/$alias_cmd $alias_args}
                        (( COMP_POINT += \${#COMP_LINE} ))
                        $compl_func
                    }" >> "$tmp_file"
                    new_completion="${new_completion/ -F $compl_func / -F $compl_wrapper }"
            fi
        fi

        # replace completion trigger by alias
        new_completion="${new_completion% *} $alias_name"
        echo "$new_completion" >> "$tmp_file"
    done < <(alias -p | sed -Ene "s/$alias_regex/\1 '\2' '\3'/p")
    source "$tmp_file" && rm -f "$tmp_file"
}; alias_completion

if [ -f ~/.bashrc ]; then
source ~/.bashrc
fi
