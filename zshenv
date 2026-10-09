[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Interactive non-login shells (terminal windows): don't let zsh run /etc/zshrc before
# ~/.zshrc. ~/.zshrc runs it itself, unchanged, right after the p10k instant prompt is
# drawn, so its ~45 ms of /etc/profile.d scripts no longer delay the first prompt.
# Login shells (ssh, tty) keep the normal startup order.
if [[ -o interactive && ! -o login ]]; then
  setopt NO_GLOBAL_RCS
  typeset -g _defer_global_zshrc=1
fi
