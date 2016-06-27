export PS1="\[\033[32m\]andrewcoenen:\[\033[33;1m\]\W\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

source ~/git-completion.bash

export EDITOR='atom'

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
alias gs="git status"
alias ga="git add"
alias gpo="git push origin"
alias gpu="git push upstream"
alias gco="git checkout"
alias gcp="git cherry-pick"
alias gpom="git push origin master"
alias grv="git remote -v"
alias gh="git hist"
alias glu="git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
alias git=hub
alias gbo="git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname) %(committerdate) %(authorname)' | sed 's/refs\/heads\///g'"
alias gd="git diff"
alias gacm="git add .; git commit -m"

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
