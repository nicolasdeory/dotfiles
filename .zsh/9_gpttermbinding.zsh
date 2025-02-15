# Bind  or <D-l> to run your Go binary
      function run_go_binary() {
         /opt/homebrew/bin/gpt-term
      }
      zle -N run_go_binary
      bindkey '^L' run_go_binary
      # bindkey '<D-l>' run_go_binary
