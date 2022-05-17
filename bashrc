# 1;32 = green, 1;34 = blue, 1;36 = light blue
export PS1="\[\e[1;36m\]${debian_chroot:+($debian_chroot)}\h:\w\$\[\e[0m\] "
export HISTSIZE=10000
export GIT_EDITOR=vim

# Core commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=always'
alias gnr='grep -nr'
alias grepi='grep -nri'
alias grepf='grep -s -nr --include '
alias grepc='grep -s -nr --include "*pp" --include "*\.c" --include "*\.cc" --include "*\.h"  --exclude-dir bazel---exclude-dir bazel-out --exclude-dir bazel-bin --exclude-dir bazel-testlogs --exclude-dir bin '
alias grepgroovy='grep -s -nr --include "*groovy"  --exclude-dir bazel-* --exclude-dir bin '
alias grepj='grep -s -nr --include "*java" --include "*scala" --exclude-dir bazel-* --exclude-dir bin '
alias grepjs='grep -s -nr --include "*js" --exclude-dir bazel-* --exclude-dir bin '
alias grepsc='grep -s -nr --include "*scala" --exclude-dir bazel-* --exclude-dir bin '
alias grepts='grep -s -nr --include "*ts" --exclude-dir bazel-* --exclude-dir bin '
alias greppy='grep -s -nr --include "*py" --exclude-dir bazel-* --exclude-dir bin '
alias grepsh='grep -s -nr --include "*sh" --exclude-dir bazel-* --exclude-dir bin '
alias grepgo='grep -s -nr --include "*go" --exclude-dir bazel-* --exclude-dir bin '
alias grepb='grep -s -nr --include "BUILD" --include "*\.bzl" --exclude-dir bazel-* --exclude-dir bin '
alias grepmd='grep -nr --include "*md" --exclude-dir bazel-* --exclude-dir bin '
alias grepi='grep -i'
grepnc='grep --color=never'
alias man='man -a'
# Note: the default colors use a very dark hue of blue to show directory
# names, this one works better.
export LSCOLORS=ExFxBxDxCxegedabagacad
alias ls='ls --color=auto'
alias l='ls --color=auto'
alias la='ls -A --color=auto'
alias ll='ls -alF --color=auto'
alias pd='pushd'
alias lynx='lynx -accept_all_cookies'
function rmcolor {
	if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -E "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
	else
    sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
	fi
}
alias gfiles='sed "s/:.*//" | rmcolor | grep -v "Binary file" | sort -u'
alias xvim='rmcolor | xargs -o vim'
alias xvim='rmcolor | xargs -o vim'
alias xv='rmcolor | gfiles | xvim'
function xo {
  find . -name "*$1*" | xv
}
function typora {
  # typora cannot create a non-existent file.
  touch $1
  /Applications/Typora.app/Contents/MacOS/Typora $1 2>/dev/null &
}

# Git aliases
alias gitb='git branch'
function gitc {
	branch="${@: -1}"
	if [[ "$#" -gt 1 ]]; then
		git checkout $*
		return
	elif [[ "$branch" == "-" ]]; then
		git checkout -
		return
	elif [[ ! $(git branch --list $branch >/dev/null) ]]; then
		git checkout $branch
		return
	fi
	branches=($(git branch | grepnc $branch | sed 's/^\* //'))
	if [[ ${#branches[@]} -eq 0 ]]; then
		# No such branch, try checking out from origin
		echo -e "\e[31mbranch not found locally, trying to check-out...\e[39m"
		git checkout $1
	elif [[ ${#branches[@]} -gt 1 ]]; then
		echo -e "\e[31mmultiple matches\e[39m:"
		printf '%s\n' "${branches[@]}"
	else
		git checkout ${branches[0]}
	fi
}

alias gitcp='git cherry-pick -x -e '
alias gitg='git log --pretty=oneline --abbrev-commit'
alias gits='git status -uno . | head -n 48'
alias gitpm='git push origin HEAD:refs/for/master'
alias gpr='git pull --rebase'
alias grc='git rebase --continue'
alias gitlint='git diff HEAD^ | grep diff.*git | sed "s/.*git a.//" | sed "s/ .*//" | xargs ./git_scripts/cpplint.py'
alias gitaddmend='git commit -a --no-edit --amend'
alias gitamend='git commit -n --no-edit --amend'
function gitsort {
	git for-each-ref --sort=-committerdate \
		--format="%(refname)" \
		refs/heads/ | \
		sed 's/refs\/heads\///' | \
		head -50
}
function precommit_disable {
	mv .git/hooks/pre-commit .git/hooks/pre-commit.bkp
}
function precommit_enable {
	[[ -f .git/hooks/pre-commit.bkp ]] && mv .git/hooks/pre-commit.bkp .git/hooks/pre-commit
}
function precommit_status {
	[[ -f .git/hooks/pre-commit ]] && echo enabled
}
function gitdone {
	set -x
	git checkout master
	git pull --rebase
	git checkout -
	git rebase master
	git checkout master
	local prev_branch=$(git rev-parse --symbolic-full-name @{-1} | sed 's/refs\/heads\///')
	git branch -d $prev_branch
	set +x
}
function gitupdate {
	set -x
	git checkout master
	git pull --rebase
	git checkout -
	git rebase master
	set +x
}
function failed_tests {
	dxi /bin/bash -c "find bazel-testlogs/ -name test.log | xargs grep There.*failure"
}
alias gitclear='git status -u | grep "^\t" | xargs rm -f'

# tmux
alias tmattach='tmux attach -t'
alias tmls='tmux list-sessions'
alias tmnew='tmux new-session -s '
alias tmkill='tmux kill-session -s '

# Docker, k8s
alias k='kubectl'

# Misc
alias myip='wget http://ipinfo.io/ip -qO -'
alias ns='cd ~/work/netspring'

function top {
	if [[ "$OSTYPE" == "darwin"* ]]; then
		top -u
	else
		/usr/bin/env top
	fi
}

# Terminal
function t {
  ITERM2_TITLE=$1
  echo -e "\033];$ITERM2_TITLE\007"
}

function latest {
  for entry in $(ls -t | head -n 1); do
    if [[ -d $entry ]]; then
      cd $entry
    fi
  done
}

function run_till_failure {
  NICE=$1
  shift
  while true; do
    nice -n $NICE $*
    if [ $? -ne 0 ]; then
      break;
    fi
  done
}
