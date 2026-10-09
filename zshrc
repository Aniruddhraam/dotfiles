# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"

# CUDA toolkit (nvcc)
export PATH="/usr/local/cuda/bin:$PATH"


# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# History Configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write timestamp & elapsed time to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate entry if new one is typed
setopt HIST_FIND_NO_DUPS         # Do not display duplicate results during search
setopt HIST_IGNORE_SPACE         # Do not record entries starting with a space
setopt HIST_SAVE_NO_DUPS         # Do not write duplicate entries to the history file
setopt SHARE_HISTORY             # Share history across all active terminals
setopt AUTO_CD                   # Type directory name to cd into it automatically
setopt AUTO_PUSHD                # cd pushes the old directory onto the stack (cd -<TAB>)
setopt PUSHD_IGNORE_DUPS         # No duplicates in the directory stack
setopt PUSHD_SILENT              # Don't print the stack after pushd/popd
setopt INTERACTIVE_COMMENTS      # Allow # comments at the interactive prompt
setopt NO_BEEP                   # No terminal bell on errors

# Never write secrets to the history file: secret-looking env assignments, --password/--token
# style flags, bearer auth headers and well-known token prefixes are dropped before saving
_hist_filter() {
  emulate -L zsh -o extendedglob
  [[ $1 != *(BW_SESSION|TOKEN|SECRET|PASSWORD|PASSWD|API_KEY)*=* &&
     $1 != *--(password|passwd|token|api-key|secret)(=|[[:space:]])* &&
     $1 != (#i)*authorization:*bearer* &&
     $1 != *(ghp_|gho_|github_pat_|sk-ant-|xoxb-|xoxp-|AKIA)[A-Za-z0-9]* ]]
}
autoload -Uz add-zsh-hook && add-zsh-hook zshaddhistory _hist_filter

# Autosuggestions async non-blocking search
export ZSH_AUTOSUGGEST_USE_ASYNC=1

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# Skip the per-startup compaudit directory-permission scan (single-user machine)
ZSH_DISABLE_COMPFIX="true"

# zsh-completions ships its definitions in src/; must be on fpath before compinit
fpath+="${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src"

# fzf-tab must load before plugins that wrap ZLE widgets (autosuggestions, syntax-highlighting)
plugins=(
  git
  fzf-tab
  zsh-autosuggestions
  sudo
  copypath
  copyfile
  zsh-syntax-highlighting
)

# Keep the completion dump in the cache dir instead of $HOME
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${HOST}-${ZSH_VERSION}"
[[ -d ${ZSH_COMPDUMP:h} ]] || mkdir -p "${ZSH_COMPDUMP:h}"

# No url-quote-magic / bracketed-paste-magic: they made large pastes take seconds and
# inserted backslashes into URLs pasted inside quotes
DISABLE_MAGIC_FUNCTIONS=true

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor
export EDITOR='nvim'
export VISUAL='nvim'

# FZF integration (fuzzy search for history Ctrl+R, files Ctrl+T, directories Alt+C)
# Cache the output of slow `eval "$(tool init)"` calls; regenerated when the binary changes
_cache_eval() {
  local name=$1; shift
  local bin=${commands[$1]}
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/$name.zsh"
  if [[ ! -s $cache || $bin -nt $cache ]]; then
    mkdir -p "${cache:h}"
    "$@" >| "$cache.tmp" && mv -f "$cache.tmp" "$cache"
  fi
  source "$cache"
}

# fzf defaults: use fd (respects .gitignore) and add previews
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
command -v bat &>/dev/null && export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :200 {}'"
command -v eza &>/dev/null && export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=always {}'"
export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border"

if command -v fzf &>/dev/null; then
  _cache_eval fzf fzf --zsh
fi

# Modern CLI Aliases
if command -v eza &>/dev/null; then
  alias ls="eza --icons=auto"
  alias ll="eza -la --icons=auto --git"
  alias la="eza -a --icons=auto"
  alias lt="eza --tree --level=2 --icons=auto"
fi

if command -v bat &>/dev/null; then
  alias cat="bat --paging=never"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# grep runs on ripgrep whenever rg can produce the same result, in pipes too; otherwise it
# falls back to GNU grep. rg runs with -uuu (no ignore files, hidden and binary files
# included), so it searches the same files grep does.
#   - flags: -i -y -v -w -x -c -l -L -n -H -h -o -q -s -a -b -Z -r -R -I -E -F -G -P,
#     -e PAT, -m N, -A/-B/-C N, -NUM, their long forms, --color, --include/--exclude/
#     --exclude-dir and --binary-files. Any other flag falls back to grep.
#   - patterns: basic (default) and -E regexes are rewritten into rg syntax (e.g. \| \( \{ \+
#     become operators, bare | ( { + become literals). Anything rg can't express the same way
#     (back-references, [[] brackets, GNU-only escapes, newline-separated lists) falls back.
#   - at the terminal rg adds smart case and its grouped, line-numbered output; piped or
#     captured output stays plain grep-style lines with grep's case sensitivity.
#   - no file and stdin is the terminal: rg searches the current directory instead of waiting.

# Rewrite a POSIX basic (bre) or extended (ere) regex into rg syntax in $REPLY; return 1 if the
# meaning can't be kept exactly.
_grep_re2rg() {
  emulate -L zsh -o extendedglob
  local re=$1 mode=$2 out= c n body
  local -i i=1 len=${#1} start=1   # start: at a spot where * is literal and ^ is an anchor
  [[ $re == *$'\n'* ]] && return 1
  while (( i <= len )); do
    c=$re[i]
    if [[ $c == '[' ]]; then
      # [:class:] is the only nested [ both engines read the same way
      [[ $re[i,-1] =~ '^\[\^?\]?([^][]|\[:[a-z]+:\])*\]' ]] || return 1
      body=$MATCH
      [[ $body == *('&&'|'--'|'~~')* ]] && return 1   # rg class set operators
      out+=${body//\\/\\\\}                           # \ is literal in POSIX brackets
      (( i += ${#body} )); start=0
      continue
    fi
    if [[ $c == \\ ]]; then
      n=$re[i+1]; (( i += 2 ))
      [[ -n $n ]] || return 1
      if [[ $mode == bre && $n == [\|\(\)\{\}+?] ]]; then
        case $n in
          '(') out+='('; start=1; continue ;;
          '|') out+='|'; start=1; continue ;;
          '{') (( start )) && return 1; out+='{'; [[ $re[i] == , ]] && out+=0 ;;  # \{,m\} -> {0,m}
          *)   (( start )) && [[ $n == [+?] ]] && return 1; out+=$n ;;
        esac
      elif [[ $n == [.*\[\]^\$\\+?\(\)\{\}\|] ]]; then out+="\\$n"
      elif [[ $n == [wWsSbB\<\>] ]]; then out+="\\$n"
      elif [[ $n == ([[:punct:]]|' ') && $n != [\`\'] ]]; then out+=$n
      else return 1   # back-references, \` \' and other GNU-only escapes
      fi
      start=0
      continue
    fi
    (( i++ ))
    if [[ $mode == bre ]]; then
      case $c in
        [\|\(\)\{\}+?]) out+="\\$c" ;;
        '*') (( start )) && out+='\*' || out+='*' ;;
        '^') if (( start )); then out+='^'; continue; else out+='\^'; fi ;;
        '$') [[ i -gt len || $re[i,i+1] == ('\)'|'\|') ]] && out+='$' || out+='\$' ;;
        *)   out+=$c ;;
      esac
    else
      case $c in
        '(') out+='('; start=1; continue ;;
        '|') out+='|'; start=1; continue ;;
        '^') out+='^'; continue ;;
        '{')
          if [[ $re[i-1,-1] =~ '^\{([0-9]+(,[0-9]*)?|,[0-9]+)\}' ]]; then
            (( start )) && return 1
            [[ $MATCH == '{,'* ]] && out+="{0${MATCH#\{}" || out+=$MATCH   # {,m} -> {0,m}
            (( i += ${#MATCH} - 1 ))
          else
            out+='\{'
          fi ;;
        '}') out+='\}' ;;
        [*+?]) (( start )) && return 1; out+=$c ;;
        *) out+=$c ;;
      esac
    fi
    start=0
  done
  REPLY=$out
}

# Build the rg argv for a grep command line in $reply; return 1 when it needs GNU grep.
_grep_rg_argv() {
  emulate -L zsh -o extendedglob
  local mode=bre arg opt val cl c p
  local -i recursive=0 skip_binary=0 case_flag=0 opts_done=0 have_e=0 only=0 invert=0
  local -a pats rpats eargs paths flags engine
  reply=()
  while (( $# )); do
    arg=$1; shift
    if (( opts_done )) || [[ $arg != -?* ]]; then
      paths+=("$arg")
    elif [[ $arg == -- ]]; then
      opts_done=1
    elif [[ $arg == --* ]]; then
      opt=${arg%%=*}; val=${${(M)arg:#*=*}#*=}
      case $opt in
        --ignore-case)            flags+=(-i); case_flag=1 ;;
        --invert-match)           flags+=(-v); invert=1 ;;
        --word-regexp)            flags+=(-w) ;;
        --line-regexp)            flags+=(-x) ;;
        --count)                  flags+=(-c --include-zero) ;;
        --files-with-matches)     flags+=(-l) ;;
        --files-without-match)    flags+=(--files-without-match) ;;
        --line-number)            flags+=(-n) ;;
        --with-filename)          flags+=(-H) ;;
        --no-filename)            flags+=(--no-filename) ;;
        --only-matching)          flags+=(-o); only=1 ;;
        --quiet|--silent)         flags+=(-q) ;;
        --no-messages)            flags+=(--no-messages) ;;
        --text)                   flags+=(-a) ;;
        --byte-offset)            flags+=(-b) ;;
        --null)                   flags+=(--null) ;;
        --line-buffered)          flags+=(--line-buffered) ;;
        --fixed-strings)          mode=fixed ;;
        --extended-regexp)        mode=ere ;;
        --basic-regexp)           mode=bre ;;
        --perl-regexp)            mode=pcre ;;
        --recursive)              recursive=1 ;;
        --dereference-recursive)  recursive=1; flags+=(-L) ;;
        --color|--colour)         flags+=(--color "${val:-auto}") ;;
        --binary-files)
          case $val in
            binary) ;;
            text) flags+=(-a) ;;
            without-match) skip_binary=1 ;;
            *) return 1 ;;
          esac ;;
        --max-count|--after-context|--before-context|--context|--regexp|--include|--exclude|--exclude-dir)
          if [[ $arg != *=* ]]; then (( $# )) || return 1; val=$1; shift; fi
          case $opt in
            --max-count)      flags+=(-m "$val") ;;
            --after-context)  flags+=(-A "$val") ;;
            --before-context) flags+=(-B "$val") ;;
            --context)        flags+=(-C "$val") ;;
            --regexp)         pats+=("$val"); have_e=1 ;;
            --include)        flags+=(-g "$val") ;;
            --exclude)        flags+=(-g "!$val") ;;
            --exclude-dir)    flags+=(-g "!$val/") ;;
          esac ;;
        *) return 1 ;;
      esac
    elif [[ $arg == -[0-9]## ]]; then
      flags+=(-C "${arg#-}")
    else
      cl=${arg#-}
      while [[ -n $cl ]]; do
        c=$cl[1]; cl=$cl[2,-1]
        case $c in
          [ABCme])
            if [[ -n $cl ]]; then val=$cl; cl=; else (( $# )) || return 1; val=$1; shift; fi
            case $c in
              e) pats+=("$val"); have_e=1 ;;
              *) flags+=(-$c "$val") ;;
            esac ;;
          [iy])       flags+=(-i); case_flag=1 ;;
          [vwxlnHoqab]) flags+=(-$c); [[ $c == o ]] && only=1; [[ $c == v ]] && invert=1 ;;
          c) flags+=(-c --include-zero) ;;   # rg -c alone hides files with 0 matches
          L) flags+=(--files-without-match) ;;
          h) flags+=(--no-filename) ;;
          s) flags+=(--no-messages) ;;       # rg -s means case-sensitive
          Z) flags+=(--null) ;;
          r) recursive=1 ;;
          R) recursive=1; flags+=(-L) ;;
          I) skip_binary=1 ;;                # rg -I means --no-filename
          E) mode=ere ;;
          F) mode=fixed ;;
          G) mode=bre ;;
          P) mode=pcre ;;
          *) return 1 ;;
        esac
      done
    fi
  done

  if (( !have_e )); then
    (( $#paths )) || return 1
    pats=("$paths[1]"); paths=("${(@)paths[2,-1]}")
  fi
  case $mode in
    fixed) [[ ${(j::)pats} == *$'\n'* ]] && return 1; flags+=(-F); rpats=("${pats[@]}") ;;
    pcre)  flags+=(-P); rpats=("${pats[@]}") ;;
    *)     for p in "${pats[@]}"; do _grep_re2rg "$p" $mode || return 1; rpats+=("$REPLY"); done ;;
  esac
  for p in "${rpats[@]}"; do eargs+=(-e "$p"); done
  # Make sure rg accepts the regex before handing it the (possibly piped) input
  if [[ $mode != fixed && ${(j::)rpats} == *[^[:alnum:][:space:]_./:-]* ]]; then
    command rg -q ${${(M)mode:#pcre}:+-P} "${eargs[@]}" -- /dev/null 2>/dev/null
    (( $? == 2 )) && return 1
  fi
  # grep -o skips empty matches and prints nothing with -v; rg doesn't
  if (( only )); then
    (( invert )) && return 1
    print | command rg -q ${${(M)mode:#pcre}:+-P} ${${(M)mode:#fixed}:+-F} "${eargs[@]}" 2>/dev/null && return 1
  fi

  if (( !$#paths )) && [[ ! -t 0 ]]; then
    (( recursive )) && return 1   # grep -r with no path searches ., ignoring stdin
    paths=(-)                     # otherwise read stdin, even when it isn't a pipe
  fi

  engine=(-uuu); (( skip_binary )) && engine=(-uu)
  [[ -t 1 ]] && (( !case_flag )) && engine+=(-S)
  reply=("${engine[@]}" "${flags[@]}" "${eargs[@]}" -- "${paths[@]}")
}

unalias grep 2>/dev/null
grep() {
  if (( $+commands[rg] )) && _grep_rg_argv "$@"; then
    if [[ -t 1 ]]; then
      command rg "${reply[@]}"
    else
      # rg reports binary-file matches on stdout; grep reports them on stderr
      command rg "${reply[@]}" | command awk '
        /^(.*: )?binary file matches \(found "\\0" byte around offset [0-9]+\)$/ { print "grep: " $0 > "/dev/stderr"; next }
        { print }'
      return $pipestatus[1]
    fi
  else
    command grep --color=auto "$@"
  fi
}

alias v="nvim"
alias vim="nvim"
alias lg="lazygit"

# Image viewer for Ghostty / Kitty (Kitty Graphics Protocol)
if command -v kitten &>/dev/null; then
  alias icat="kitten icat"
elif command -v chafa &>/dev/null; then
  alias icat="chafa -f kitty"
fi

# Completion styling (fzf-tab renders the menu, so disable zsh's own)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' group-name ''
zstyle ':fzf-tab:*' switch-group '<' '>'
if command -v eza &>/dev/null; then
  zstyle ':fzf-tab:complete:(cd|__zoxide_z|z|ls|eza):*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
fi

# QoL aliases/functions (new names only; existing commands keep their default behaviour)
alias sudo='sudo '            # lets aliases expand after sudo
alias dfh='df -h'
alias duh='du -h --max-depth=1 | sort -h'
alias ports='ss -tulpn'
alias bcat='bat'
alias reload='exec zsh'
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ==============================================================================
# Universal Archive Extractor (extract) - Verbose & Max Multithreading
# ==============================================================================
extract() {
  if [ $# -eq 0 ]; then
    echo "Usage: extract <archive_file(s)>"
    return 1
  fi

  local threads=$(nproc 2>/dev/null || echo 0)

  for file in "$@"; do
    if [ ! -f "$file" ]; then
      echo "extract: '$file' is not a valid file"
      continue
    fi

    echo "==> Extracting '$file' (threads: ${threads:-all})..."
    case "${file:l}" in
      *.tar.bz2|*.tbz|*.tbz2)
        if command -v lbzip2 &>/dev/null; then
          lbzip2 -d -c -n "$threads" "$file" | tar -xvf -
        elif command -v pbzip2 &>/dev/null; then
          pbzip2 -d -c -p"$threads" "$file" | tar -xvf -
        else
          tar -xvjf "$file"
        fi ;;
      *.tar.gz|*.tgz|*.taz)
        if command -v pigz &>/dev/null; then
          pigz -d -c -p "$threads" "$file" | tar -xvf -
        else
          tar -xvzf "$file"
        fi ;;
      *.tar.xz|*.txz)
        tar -I "xz -d -T0" -xvf "$file" 2>/dev/null || tar -xvJf "$file" ;;
      *.tar.zst|*.tzst)
        tar -I "zstd -d -T0" -xvf "$file" 2>/dev/null || zstd -d -c -T0 -v "$file" | tar -xvf - ;;
      *.tar.lz4|*.tlz4)
        if ! command -v lz4 &>/dev/null; then
          echo "Error: lz4 is not installed. Run: sudo dnf install lz4"
        else
          lz4 -d -c -v "$file" | tar -xvf -
        fi ;;
      *.tar.lz|*.tlz|*.tar.lzip)
        if command -v plzip &>/dev/null; then
          plzip -d -c -n "$threads" "$file" | tar -xvf -
        elif command -v lzip &>/dev/null; then
          lzip -d -c -v "$file" | tar -xvf -
        else
          echo "Error: lzip/plzip is not installed. Run: sudo dnf install lzip"
        fi ;;
      *.tar.lzma)
        tar -I "xz --format=lzma -d -T0" -xvf "$file" 2>/dev/null || tar --lzma -xvf "$file" ;;
      *.tar.lzo|*.tlzo)
        if ! command -v lzop &>/dev/null; then
          echo "Error: lzop is not installed. Run: sudo dnf install lzop"
        else
          lzop -d -c -v "$file" | tar -xvf -
        fi ;;
      *.tar)
        tar -xvf "$file" ;;
      *.bz2)
        if command -v lbzip2 &>/dev/null; then
          lbzip2 -d -k -n "$threads" -v "$file"
        elif command -v pbzip2 &>/dev/null; then
          pbzip2 -d -k -p"$threads" -v "$file"
        else
          bunzip2 -v -k "$file"
        fi ;;
      *.gz)
        if command -v pigz &>/dev/null; then
          pigz -d -k -p "$threads" -v "$file"
        else
          gunzip -v -k "$file"
        fi ;;
      *.xz)
        unxz -T0 -v -k "$file" 2>/dev/null || unxz -v -k "$file" ;;
      *.zst)
        unzstd -T0 -v -k "$file" 2>/dev/null || unzstd -v -k "$file" ;;
      *.lz4)
        if ! command -v lz4 &>/dev/null; then
          echo "Error: lz4 is not installed. Run: sudo dnf install lz4"
        else
          lz4 -d -v "$file"
        fi ;;
      *.lz)
        if command -v plzip &>/dev/null; then
          plzip -d -k -n "$threads" -v "$file"
        elif command -v lzip &>/dev/null; then
          lzip -d -v -k "$file"
        else
          echo "Error: lzip is not installed. Run: sudo dnf install lzip"
        fi ;;
      *.lzma)
        xz --format=lzma -d -T0 -v -k "$file" 2>/dev/null || unlzma -v -k "$file" ;;
      *.lzo)
        if ! command -v lzop &>/dev/null; then
          echo "Error: lzop is not installed. Run: sudo dnf install lzop"
        else
          lzop -d -v "$file"
        fi ;;
      *.br)
        if ! command -v brotli &>/dev/null; then
          echo "Error: brotli is not installed. Run: sudo dnf install brotli"
        else
          brotli -d -v -k "$file"
        fi ;;
      *.zip|*.jar|*.war|*.ear|*.xpi|*.apk)
        if command -v 7z &>/dev/null; then
          7z x -y -mmt=on "$file"
        else
          unzip -v "$file" && unzip -o "$file"
        fi ;;
      *.7z)
        7z x -y -mmt=on "$file" ;;
      *.rar)
        if command -v unrar &>/dev/null; then
          unrar x -v "$file"
        elif command -v unar &>/dev/null; then
          unar -v "$file"
        elif command -v 7z &>/dev/null; then
          7z x -y -mmt=on "$file"
        else
          echo "Error: neither unrar, unar, nor 7z is installed."
        fi ;;
      *.cab)
        if ! command -v cabextract &>/dev/null; then
          echo "Error: cabextract is not installed. Run: sudo dnf install cabextract"
        else
          cabextract -v "$file"
        fi ;;
      *.cpio)
        cpio -idmv < "$file" ;;
      *.rpm)
        rpm2cpio "$file" | cpio -idmv ;;
      *.deb)
        ar -xv "$file" ;;
      *.iso|*.dmg)
        if command -v 7z &>/dev/null; then
          7z x -mmt=on "$file"
        elif command -v unar &>/dev/null; then
          unar -v "$file"
        fi ;;
      *.z)
        uncompress -v "$file" ;;
      *)
        if command -v unar &>/dev/null; then
          echo "Attempting fallback extraction with unar..."
          unar -v "$file"
        else
          echo "extract: '$file' cannot be extracted via extract()"
        fi ;;
    esac
  done
}

# ==============================================================================
# Universal Archive Creator (compress) - Verbose & Max Multithreading
# Syntax: compress <compression_type> <file_or_directory> [level]
# ==============================================================================
compress() {
  if [ $# -lt 2 ]; then
    echo "Usage: compress <type> <file_or_directory> [level]"
    echo "Examples:"
    echo "  compress tar.zst mydir -19"
    echo "  compress 7z mydir -9"
    echo "  compress zip file.txt -9"
    echo "Run 'compress <TAB>' or 'compress <type> <target> <TAB>' to explore options."
    return 1
  fi

  local ctype="${1:l}"
  local target="${2%/}" # Strip trailing slash if present
  local lvl_arg="${3#-}" # Strip leading dash if passed as -9
  local threads=$(nproc 2>/dev/null || echo 0)

  if [ ! -e "$target" ]; then
    echo "compress: '$target' does not exist"
    return 1
  fi

  local is_dir=0
  [ -d "$target" ] && is_dir=1

  case "$ctype" in
    tar.gz|tgz)
      local gz_cmd="gzip"
      if command -v pigz &>/dev/null; then
        gz_cmd="pigz -p $threads"
        [ -n "$lvl_arg" ] && gz_cmd="pigz -p $threads -${lvl_arg}"
      else
        [ -n "$lvl_arg" ] && gz_cmd="gzip -${lvl_arg}"
      fi
      tar -I "$gz_cmd" -cvf "${target}.tar.gz" "$target" ;;
    tar.bz2|tbz2|tbz)
      local bz_cmd="bzip2"
      if command -v lbzip2 &>/dev/null; then
        bz_cmd="lbzip2 -n $threads"
        [ -n "$lvl_arg" ] && bz_cmd="lbzip2 -n $threads -${lvl_arg}"
      elif command -v pbzip2 &>/dev/null; then
        bz_cmd="pbzip2 -p$threads"
        [ -n "$lvl_arg" ] && bz_cmd="pbzip2 -p$threads -${lvl_arg}"
      else
        [ -n "$lvl_arg" ] && bz_cmd="bzip2 -${lvl_arg}"
      fi
      tar -I "$bz_cmd" -cvf "${target}.tar.bz2" "$target" ;;
    tar.xz|txz)
      local xz_cmd="xz -T0"
      [ -n "$lvl_arg" ] && xz_cmd="xz -T0 -${lvl_arg}"
      tar -I "$xz_cmd" -cvf "${target}.tar.xz" "$target" ;;
    tar.zst|tzst)
      local zst_cmd="zstd -T0"
      if [ -n "$lvl_arg" ]; then
        if [ "$lvl_arg" -gt 19 ] 2>/dev/null; then
          zst_cmd="zstd --ultra -${lvl_arg} -T0"
        else
          zst_cmd="zstd -${lvl_arg} -T0"
        fi
      fi
      tar -I "$zst_cmd" -cvf "${target}.tar.zst" "$target" ;;
    tar.lz4)
      if ! command -v lz4 &>/dev/null; then
        echo "Error: lz4 is not installed. Run: sudo dnf install lz4"
        return 1
      fi
      local lz4_cmd="lz4"
      [ -n "$lvl_arg" ] && lz4_cmd="lz4 -${lvl_arg}"
      tar -I "$lz4_cmd" -cvf "${target}.tar.lz4" "$target" ;;
    tar.lzip|tar.lz)
      local lz_cmd="lzip"
      if command -v plzip &>/dev/null; then
        lz_cmd="plzip -n $threads"
        [ -n "$lvl_arg" ] && lz_cmd="plzip -n $threads -${lvl_arg}"
      elif command -v lzip &>/dev/null; then
        [ -n "$lvl_arg" ] && lz_cmd="lzip -${lvl_arg}"
      else
        echo "Error: lzip/plzip is not installed. Run: sudo dnf install lzip"
        return 1
      fi
      tar -I "$lz_cmd" -cvf "${target}.tar.lz" "$target" ;;
    tar.lzma)
      local lzma_cmd="xz --format=lzma -T0"
      [ -n "$lvl_arg" ] && lzma_cmd="xz --format=lzma -T0 -${lvl_arg}"
      tar -I "$lzma_cmd" -cvf "${target}.tar.lzma" "$target" ;;
    tar.lzo)
      if ! command -v lzop &>/dev/null; then
        echo "Error: lzop is not installed. Run: sudo dnf install lzop"
        return 1
      fi
      local lzo_cmd="lzop"
      [ -n "$lvl_arg" ] && lzo_cmd="lzop -${lvl_arg}"
      tar -I "$lzo_cmd" -cvf "${target}.tar.lzo" "$target" ;;
    tar)
      tar -cvf "${target}.tar" "$target" ;;
    zip)
      if command -v 7z &>/dev/null; then
        local s7_opt="-tzip -mmt=on"
        [ -n "$lvl_arg" ] && s7_opt="-tzip -mmt=on -mx=${lvl_arg}"
        7z a ${=s7_opt} "${target}.zip" "$target"
      else
        local zip_opt=""
        [ -n "$lvl_arg" ] && zip_opt="-${lvl_arg}"
        zip -rv ${=zip_opt} "${target}.zip" "$target"
      fi ;;
    7z)
      local s7_opt="-mmt=on"
      [ -n "$lvl_arg" ] && s7_opt="-mmt=on -mx=${lvl_arg}"
      7z a ${=s7_opt} "${target}.7z" "$target" ;;
    rar)
      if ! command -v rar &>/dev/null; then
        echo "Error: rar is not installed. Run: sudo dnf install rar"
        return 1
      fi
      local rar_opt=""
      [ -n "$lvl_arg" ] && rar_opt="-m${lvl_arg}"
      rar a -v ${rar_opt} "${target}.rar" "$target" ;;
    gz)
      if command -v pigz &>/dev/null; then
        local gz_opt="-p $threads"
        [ -n "$lvl_arg" ] && gz_opt="-p $threads -${lvl_arg}"
        if [ $is_dir -eq 1 ]; then
          echo "Note: '$target' is a directory; archiving into '${target}.tar.gz'..."
          tar -I "pigz ${gz_opt}" -cvf "${target}.tar.gz" "$target"
        else
          pigz -v -c ${=gz_opt} "$target" > "${target}.gz"
        fi
      else
        local gz_opt=""
        [ -n "$lvl_arg" ] && gz_opt="-${lvl_arg}"
        if [ $is_dir -eq 1 ]; then
          echo "Note: '$target' is a directory; archiving into '${target}.tar.gz'..."
          local gz_cmd="gzip"
          [ -n "$lvl_arg" ] && gz_cmd="gzip -${lvl_arg}"
          tar -I "$gz_cmd" -cvf "${target}.tar.gz" "$target"
        else
          gzip -v -c ${gz_opt} "$target" > "${target}.gz"
        fi
      fi ;;
    bz2)
      if command -v lbzip2 &>/dev/null; then
        local bz_opt="-n $threads"
        [ -n "$lvl_arg" ] && bz_opt="-n $threads -${lvl_arg}"
        if [ $is_dir -eq 1 ]; then
          echo "Note: '$target' is a directory; archiving into '${target}.tar.bz2'..."
          tar -I "lbzip2 ${bz_opt}" -cvf "${target}.tar.bz2" "$target"
        else
          lbzip2 -v -c ${=bz_opt} "$target" > "${target}.bz2"
        fi
      elif command -v pbzip2 &>/dev/null; then
        local bz_opt="-p$threads"
        [ -n "$lvl_arg" ] && bz_opt="-p$threads -${lvl_arg}"
        if [ $is_dir -eq 1 ]; then
          echo "Note: '$target' is a directory; archiving into '${target}.tar.bz2'..."
          tar -I "pbzip2 ${bz_opt}" -cvf "${target}.tar.bz2" "$target"
        else
          pbzip2 -v -c ${=bz_opt} "$target" > "${target}.bz2"
        fi
      else
        local bz_opt=""
        [ -n "$lvl_arg" ] && bz_opt="-${lvl_arg}"
        if [ $is_dir -eq 1 ]; then
          echo "Note: '$target' is a directory; archiving into '${target}.tar.bz2'..."
          local bz_cmd="bzip2"
          [ -n "$lvl_arg" ] && bz_cmd="bzip2 -${lvl_arg}"
          tar -I "$bz_cmd" -cvf "${target}.tar.bz2" "$target"
        else
          bzip2 -v -c ${bz_opt} "$target" > "${target}.bz2"
        fi
      fi ;;
    xz)
      local xz_opt="-T0"
      [ -n "$lvl_arg" ] && xz_opt="-T0 -${lvl_arg}"
      if [ $is_dir -eq 1 ]; then
        echo "Note: '$target' is a directory; archiving into '${target}.tar.xz'..."
        tar -I "xz ${xz_opt}" -cvf "${target}.tar.xz" "$target"
      else
        xz -v -c ${=xz_opt} "$target" > "${target}.xz"
      fi ;;
    zst)
      local zst_opt="-T0"
      if [ -n "$lvl_arg" ]; then
        if [ "$lvl_arg" -gt 19 ] 2>/dev/null; then
          zst_opt="--ultra -${lvl_arg} -T0"
        else
          zst_opt="-${lvl_arg} -T0"
        fi
      fi
      if [ $is_dir -eq 1 ]; then
        echo "Note: '$target' is a directory; archiving into '${target}.tar.zst'..."
        tar -I "zstd ${zst_opt}" -cvf "${target}.tar.zst" "$target"
      else
        zstd -v -c ${=zst_opt} "$target" > "${target}.zst"
      fi ;;
    lz4)
      if ! command -v lz4 &>/dev/null; then
        echo "Error: lz4 is not installed. Run: sudo dnf install lz4"
        return 1
      fi
      local lz4_opt=""
      [ -n "$lvl_arg" ] && lz4_opt="-${lvl_arg}"
      if [ $is_dir -eq 1 ]; then
        echo "Note: '$target' is a directory; archiving into '${target}.tar.lz4'..."
        tar -I "lz4 ${lz4_opt}" -cvf "${target}.tar.lz4" "$target"
      else
        lz4 -v ${lz4_opt} "$target" "${target}.lz4"
      fi ;;
    lzip|lz)
      local lz_opt=""
      if command -v plzip &>/dev/null; then
        lz_opt="-n $threads"
        [ -n "$lvl_arg" ] && lz_opt="-n $threads -${lvl_arg}"
        if [ $is_dir -eq 1 ]; then
          echo "Note: '$target' is a directory; archiving into '${target}.tar.lz'..."
          tar -I "plzip ${lz_opt}" -cvf "${target}.tar.lz" "$target"
        else
          plzip -v -c ${=lz_opt} "$target" > "${target}.lz"
        fi
      elif command -v lzip &>/dev/null; then
        [ -n "$lvl_arg" ] && lz_opt="-${lvl_arg}"
        if [ $is_dir -eq 1 ]; then
          echo "Note: '$target' is a directory; archiving into '${target}.tar.lz'..."
          tar -I "lzip ${lz_opt}" -cvf "${target}.tar.lz" "$target"
        else
          lzip -v -c ${lz_opt} "$target" > "${target}.lz"
        fi
      else
        echo "Error: lzip/plzip is not installed. Run: sudo dnf install lzip"
        return 1
      fi ;;
    lzo)
      if ! command -v lzop &>/dev/null; then
        echo "Error: lzop is not installed. Run: sudo dnf install lzop"
        return 1
      fi
      local lzo_opt=""
      [ -n "$lvl_arg" ] && lzo_opt="-${lvl_arg}"
      if [ $is_dir -eq 1 ]; then
        echo "Note: '$target' is a directory; archiving into '${target}.tar.lzo'..."
        tar -I "lzop ${lzo_opt}" -cvf "${target}.tar.lzo" "$target"
      else
        lzop -v -c ${lzo_opt} "$target" > "${target}.lzo"
      fi ;;
    br)
      if ! command -v brotli &>/dev/null; then
        echo "Error: brotli is not installed. Run: sudo dnf install brotli"
        return 1
      fi
      local br_opt=""
      [ -n "$lvl_arg" ] && br_opt="-q ${lvl_arg}"
      if [ $is_dir -eq 1 ]; then
        echo "Error: brotli does not support directories directly. Use tar.gz, tar.zst, or zip."
        return 1
      else
        brotli -v -c ${br_opt} "$target" > "${target}.br"
      fi ;;
    cpio)
      find "$target" -depth | cpio -ov > "${target}.cpio" ;;
    *)
      echo "compress: unsupported compression type '$ctype'"
      echo "Run 'compress <TAB>' to see available types."
      return 1 ;;
  esac

  echo "==> Created: ${target}.${ctype}"
}

# ------------------------------------------------------------------------------
# Zsh Tab Completion for 'compress' command
# ------------------------------------------------------------------------------
_compress() {
  local -a formats
  formats=(
    'tar.gz:Gzip compressed tarball'
    'tar.bz2:Bzip2 compressed tarball (high compression)'
    'tar.xz:XZ compressed tarball (ultra high compression)'
    'tar.zst:Zstandard compressed tarball (fast & high ratio)'
    'tar.lz4:LZ4 compressed tarball (ultra fast speed)'
    'tar.lzip:Lzip compressed tarball'
    'tar.lzma:LZMA compressed tarball'
    'tar.lzo:Lzop compressed tarball'
    'tar:Uncompressed tar archive'
    'zip:Standard ZIP archive'
    '7z:7-Zip archive (high compression)'
    'rar:RAR archive'
    'gz:Gzip compression (single file)'
    'bz2:Bzip2 compression (single file)'
    'xz:XZ compression (single file)'
    'zst:Zstandard compression (single file)'
    'lz4:LZ4 compression (single file)'
    'lzip:Lzip compression (single file)'
    'lzo:Lzop compression (single file)'
    'br:Brotli compression (single file)'
    'cpio:CPIO archive'
  )

  _arguments -C \
    '1:compression type:->type' \
    '2:target file or directory:_files' \
    '3:compression level:->level'

  case "$state" in
    type)
      _describe -t formats 'compression type' formats
      ;;
    level)
      local ctype="${words[2]:l}"
      local -a levels
      case "$ctype" in
        zst|tar.zst|tzst)
          levels=(
            '-1:Level 1 - Fastest (lowest CPU & RAM)'
            '-3:Level 3 - Default (balanced speed & ratio)'
            '-5:Level 5 - Good compression'
            '-9:Level 9 - High compression'
            '-15:Level 15 - Very high compression'
            '-19:Level 19 - Maximum standard ratio'
            '-22:Level 22 - Ultra mode (--ultra, high RAM/CPU)'
          )
          ;;
        gz|tar.gz|tgz)
          levels=(
            '-1:Level 1 - Fastest (lowest compression)'
            '-3:Level 3 - Fast'
            '-6:Level 6 - Default (balanced)'
            '-9:Level 9 - Maximum (best compression)'
          )
          ;;
        bz2|tar.bz2|tbz2|tbz)
          levels=(
            '-1:Level 1 - Fastest (100k block size)'
            '-5:Level 5 - Balanced (500k block size)'
            '-9:Level 9 - Maximum (900k block size, default)'
          )
          ;;
        xz|tar.xz|txz|tar.lzma)
          levels=(
            '-0:Level 0 - Fastest (lowest RAM)'
            '-3:Level 3 - Fast'
            '-6:Level 6 - Default (balanced)'
            '-9:Level 9 - Maximum (highest ratio, high RAM)'
          )
          ;;
        7z)
          levels=(
            '-0:Level 0 - Store only (no compression)'
            '-1:Level 1 - Fastest'
            '-3:Level 3 - Fast'
            '-5:Level 5 - Normal (default)'
            '-7:Level 7 - Maximum'
            '-9:Level 9 - Ultra (highest compression ratio)'
          )
          ;;
        zip)
          levels=(
            '-0:Level 0 - Store only (no compression)'
            '-1:Level 1 - Fastest'
            '-6:Level 6 - Default'
            '-9:Level 9 - Maximum (best compression)'
          )
          ;;
        lz4|tar.lz4)
          levels=(
            '-1:Level 1 - Fastest (default, maximum speed)'
            '-3:Level 3 - Fast'
            '-9:Level 9 - High compression (LZ4HC)'
            '-12:Level 12 - Maximum compression (LZ4HC)'
          )
          ;;
        br)
          levels=(
            '-0:Level 0 - Fastest'
            '-4:Level 4 - Default (balanced)'
            '-9:Level 9 - High compression'
            '-11:Level 11 - Maximum (best ratio)'
          )
          ;;
        lzip|lz|tar.lzip|tar.lz)
          levels=(
            '-0:Level 0 - Fastest'
            '-6:Level 6 - Default'
            '-9:Level 9 - Maximum'
          )
          ;;
        lzo|tar.lzo)
          levels=(
            '-1:Level 1 - Fastest (default)'
            '-7:Level 7 - High compression'
            '-9:Level 9 - Maximum'
          )
          ;;
        *)
          levels=('-:No compression levels applicable for this format')
          ;;
      esac
      _describe -t levels "compression level (range for $ctype)" levels
      ;;
  esac
}
compdef _compress compress

# ==============================================================================
# Automatic Bytecode Compilation (zcompile)
# Automatically compiles ~/.zshrc and ~/.p10k.zsh when changes are detected
# ==============================================================================
() {
  local zfile
  for zfile in "$HOME/.zshrc" "$HOME/.p10k.zsh"; do
    if [[ -f "$zfile" && ( ! -f "${zfile}.zwc" || "$zfile" -nt "${zfile}.zwc" ) ]]; then
      zcompile "$zfile" 2>/dev/null
    fi
  done
}






# pnpm
export PNPM_HOME='/home/aniruddh/.local/share/pnpm'
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# ==============================================================================
# DNS mode switching: dnscrypt-proxy (ODoH) <-> the network's own plain DNS
# ------------------------------------------------------------------------------
# Normal state: /etc/resolv.conf -> 127.0.0.1 (dnscrypt-proxy, ODoH, cached).
# Captive networks (e.g. university Wi-Fi login) block ODoH/relay traffic until you
# authenticate, so nothing resolves and the login portal can't load. Workflow:
#   dnsplain   -> point resolv.conf at the DHCP-provided DNS, then open http://neverssl.com
#   dnsodoh    -> after logging in, go back to encrypted ODoH DNS
#   dnsstatus  -> show which mode is active and test a lookup
# dnscrypt-proxy keeps running in both modes; only /etc/resolv.conf changes.
# Full undo of the migration is a different command: sudo odoh-migrate rollback
# ==============================================================================

# Print the interface carrying the default route (falls back to the first connected NIC).
_dns_iface() {
  local dev
  dev=$(ip route show default 2>/dev/null | awk '/default/{print $5; exit}')
  [[ -z $dev ]] && dev=$(nmcli -t -f DEVICE,STATE dev 2>/dev/null | awk -F: '$2=="connected" && $1!~/^(lo|tailscale)/{print $1; exit}')
  print -r -- "$dev"
}

# Switch to plain DNS using the first nameserver from the current network's DHCP lease.
dnsplain() {
  local dev dns
  dev=$(_dns_iface)
  dns=$(nmcli -g IP4.DNS device show "$dev" 2>/dev/null | head -1)
  if [[ -z $dns ]]; then
    echo "dnsplain: no DHCP DNS found on '${dev:-?}' (are you connected to the Wi-Fi?)" >&2
    return 1
  fi
  # tee (not >) so the redirect itself runs as root; keeps the file's SELinux context
  printf 'nameserver %s\n' "$dns" | sudo tee /etc/resolv.conf >/dev/null || return 1
  echo "==> PLAIN DNS via $dns on $dev (unencrypted; the network can see lookups)."
  echo "    Log in at http://neverssl.com, then run: dnsodoh"
}

# Switch back to the local dnscrypt-proxy (ODoH) resolver and check that it works.
dnsodoh() {
  systemctl is-active --quiet dnscrypt-proxy || sudo systemctl start dnscrypt-proxy || return 1
  printf 'nameserver 127.0.0.1\noptions edns0\n' | sudo tee /etc/resolv.conf >/dev/null || return 1
  # dig prints errors to stdout, so only a real IPv4 address counts as success
  if dig +short +time=6 +tries=1 example.com @127.0.0.1 2>/dev/null | command grep -qE '^[0-9]+(\.[0-9]+){3}$'; then
    echo "==> ODoH DNS active (dnscrypt-proxy on 127.0.0.1) and resolving."
  else
    echo "==> resolv.conf now points at dnscrypt-proxy but it isn't resolving yet." >&2
    echo "    Not logged in to the network? Run dnsplain, log in, then dnsodoh again." >&2
    return 1
  fi
}

# Show the active mode and time a lookup.
dnsstatus() {
  local ns
  ns=$(awk '/^nameserver/{print $2; exit}' /etc/resolv.conf)
  if [[ $ns == 127.0.0.1 ]]; then echo "mode: ODoH (dnscrypt-proxy, $(systemctl is-active dnscrypt-proxy))"
  else echo "mode: PLAIN via ${ns:-none}"; fi
  dig +noall +answer +stats example.com | awk '/IN/{print "  " $0} /Query time/{print "  " $0}'
}

# Friendlier names for the two modes above
portal-mode() { dnsplain; }   # plain DHCP DNS, for captive-portal login
secure-mode() { dnsodoh; }    # back to ODoH via dnscrypt-proxy

# uv: `uv add <pkg>` outside any project first creates a bare pyproject.toml (no git repo,
# README, .python-version or src/), then runs the normal add, which makes .venv.
# `uv run Q10` runs Q10.py when Q10 itself isn't a file, a command on PATH or a project script.
# Everything else, and `add` inside an existing project, passes straight through.
uv() {
  if [[ $1 == run && -n $2 && $2 != -* && ! -e $2 && -f $2.py ]] &&
     ! whence -p -- "$2" >/dev/null && [[ ! -e .venv/bin/$2 ]]; then
    set -- run "$2.py" "${@:3}"
  fi
  if [[ $1 == add ]]; then
    local arg d=$PWD
    for arg in "$@"; do
      case $arg in
        --script|--script=*|--project|--project=*|--directory|--directory=*|-h|--help)
          command uv "$@"; return ;;
      esac
    done
    # uv add finds the project by walking up, so only bootstrap when no parent has one
    while [[ ! -f $d/pyproject.toml && $d != / ]]; do d=${d:h}; done
    [[ -f $d/pyproject.toml ]] || command uv init --bare --no-workspace --vcs none || return
  fi
  command uv "$@"
}

# Update everything in one go; a failing step doesn't stop the rest, failures are listed at the end
upall() {
  local step
  local -a failed
  for step in \
    'sudo dnf upgrade --refresh -y' \
    'gup update' \
    'pnpm update -g oxfmt oxlint @oxc-node/cli @vtsls/language-server typescript basedpyright' \
    'rustup update' \
    'cargo install-update -a' \
    'uv tool upgrade --all' \
    'flatpak update -y'
  do
    print -P "%F{blue}==> $step%f"
    eval $step || failed+=("$step")
  done
  if (( $#failed )); then
    print -P "%F{red}==> failed:%f ${(j:, :)failed}"
    return 1
  fi
  print -P "%F{green}==> all up to date%f"
}

# clone <repo | owner/repo | url> [git clone flags]: clone, then cd into it.
# A bare repo name means github.com/Aniruddhraam/<repo>.
clone() {
  local url=${1:?usage: clone <repo|owner/repo|url> [git clone flags]}; shift
  if [[ $url != *(://|@)* ]]; then
    [[ $url == */* ]] || url=Aniruddhraam/$url
    url=https://github.com/$url
  fi
  git clone "$@" -- "$url" && builtin cd -- "${${url:t}%.git}"
}

# alt+j / alt+k act as down / up arrows at the prompt (same as the nvim mappings).
# Same widgets as the arrow keys, so history prefix search behaves identically.
bindkey '^[j' down-line-or-beginning-search
bindkey '^[k' up-line-or-beginning-search

# zoxide (keep last)
export _ZO_DOCTOR=0
_cache_eval zoxide zoxide init zsh --cmd cd
