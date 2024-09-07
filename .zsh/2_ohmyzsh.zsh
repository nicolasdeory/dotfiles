# If you come from bash you might have to change your $PATH.
 export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"
zstyle ':omz:update' mode auto      # update automatically without asking

plugins=(git fzf)

source $ZSH/oh-my-zsh.sh
