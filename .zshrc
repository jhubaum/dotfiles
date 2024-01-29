# Load Antigen
source "$HOME/antigen.zsh"

antigen use oh-my-zsh

antigen bundle git
antigen bundle heroku
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions

antigen theme af-magic

antigen apply

export PATH="$HOME/.local/bin:$HOME/scripts/:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# opam configuration
[[ ! -r /home/johannes/.opam/opam-init/init.zsh ]] || source /home/johannes/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

export PROJECT_FOLDERS="$HOME/projects:$HOME/.config"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
