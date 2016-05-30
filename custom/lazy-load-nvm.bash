function lazy-load-nvm () {
  unalias nvm
  unalias node
  unalias npm
  source "${BASH_IT}/plugins/available/nvm.plugin.bash"
}

alias nvm='lazy-load-nvm && nvm'
alias node='lazy-load-nvm && node'
alias npm='lazy-load-nvm && npm'
