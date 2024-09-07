# brew
#export PATH=$HOME/.oh-my-zsh/plugins/brew:$PATH
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "\$($(brew --prefix)/bin/brew shellenv)"
