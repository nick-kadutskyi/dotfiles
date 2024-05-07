# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"


# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(nvm git git-extras zsh-syntax-highlighting symfony-console)
# Lazy loads nvm to speed up shell startup time
zstyle ':omz:plugins:nvm' lazy yes

# Pre oh-my-zsh user configuration


# COMPLETIONS (need to be before oh-my-zsh since it runs compinit)

# Brew site-functions for brew packages completions
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
# Brew zsh-completions package
FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
# Google Cloud Platform (brew gcloud completion doesn't work)
GCLOUD_COMPLETION="$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
[ -f "$GCLOUD_COMPLETION" ] && source "$GCLOUD_COMPLETION"


# INIT oh-my-zsh
source $ZSH/oh-my-zsh.sh


# USER CONFIG

# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"

# For larger history file
HISTFILESIZE=1000000000
HISTSIZE=1000000


# INIT
# zsh-autosuggestions plugin
ZSH_AUTOSUGGEST_P=/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f $ZSH_AUTOSUGGEST_P ] && source $ZSH_AUTOSUGGEST_P
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# BEGIN SNIPPET: Platform.sh CLI configuration
HOME=${HOME:-'/Users/nick'}
if [ -f "$HOME/"'.platformsh/shell-config.rc' ]; then . "$HOME/"'.platformsh/shell-config.rc'; fi # END SNIPPET
# Fuzzy search
eval "$(fzf --zsh)"
# iTerm's shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# LAZY
# pyenv
if [[ -d "$PYENV_ROOT" ]]; then
  pyenv () {
    unfunction pyenv
    if ! (($path[(Ie)${PYENV_ROOT}/bin])); then
      path[1,0]="${PYENV_ROOT}/bin"
    fi
    eval "$(pyenv init -)"
    if [[ -n "${ZSH_PYENV_LAZY_VIRTUALENV}" ]]; then
         eval "$(pyenv virtualenv-init -)"
    fi
    pyenv "$@"
  }
fi


# FUNCTIONS

# Benchmark shell
timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}
# Fuzzy search functions
# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}
# fh - search in your command history and execute selected command
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}


# ALIASES (MAMP aliases are in .profile because of MAMP)

# Development
# Symfony
alias sc='symfony console'
alias sym='symfony'
# Laravel
alias mfs='php artisan migrate:fresh --seed'
alias mfss='mfs && php artisan db:seed --class=DevSeeder'
# IPs
alias ip='curl -4 icanhazip.com'
alias ip4='curl -4 icanhazip.com'
alias ip6='curl -6 icanhazip.com'
alias iplan="ifconfig en0 inet | grep 'inet ' | awk ' { print \$2 } '"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print \$1'"
alias ip4a="dig +short -4 myip.opendns.com @resolver4.opendns.com"
alias ip6a="dig +short -6 myip.opendns.com @resolver1.ipv6-sandbox.opendns.com AAAA"
# Neovim
alias vi="nvim"
alias vim="nvim"
alias view="nvim -R"
alias vimdiff="nvim -d"

# EPDS
# List EPDS AWS EC2 Instances
alias epds_ec2="aws ec2 describe-instances  --query 'Reservations[].Instances[?not_null(Tags[?Key==\`Name\`].Value)]|[].[State.Name,PrivateIpAddress,PublicIpAddress,InstanceId,Tags[?Key==\`Name\`].Value[]|[0]] | sort_by(@, &[3])' --output text |  sed '$!N;s/ / /'"

# Other
# Removes all Adobe stuff
alias nothankyouadobe="sudo -H killall ACCFinderSync \"Core Sync\" AdobeCRDaemon \"Adobe Creative\" AdobeIPCBroker node \"Adobe Desktop Service\" \"Adobe Crash Reporter\";sudo -H rm -rf \"/Library/LaunchAgents/com.adobe.AAM.Updater-1.0.plist\" \"/Library/LaunchAgents/com.adobe.AdobeCreativeCloud.plist\" \"/Library/LaunchDaemons/com.adobe.*.plist\""
