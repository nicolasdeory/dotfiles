alias ll='ls -lFa'
## List LSD Aliases
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

alias gs='git status'

# Aliases
alias zed='nvim ~/.zshrc'
alias n="nvim"
alias cat="bat"
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lazydotfiles='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias zap='git commit -m ':zap:' && ggpush'
alias gpf='read -q "REPLY?Force push to $(git branch --show-current)? (y/n) " && echo && if [[ $REPLY =~ ^[Yy]$ ]]; then git push --force origin $(git branch --show-current); else echo "Force push cancelled."; fi'
