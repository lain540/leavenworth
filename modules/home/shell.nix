{ config, pkgs, ... }:

# ── base16-default-dark palette ───────────────────────────────────────────────
# Colours are embedded as string literals via Nix let bindings so the shell
# script contains bare hex values with no runtime dependencies.
# Reference: https://github.com/tinted-theming/base16-default-schemes
let
  c = {
    bg     = "181818"; # base00 — background
    bgAlt  = "282828"; # base01 — lighter background / status bars
    sel    = "383838"; # base02 — selection background
    cmt    = "585858"; # base03 — comments / inactive / dark fg
    fgDark = "b8b8b8"; # base04 — dark foreground
    fg     = "d8d8d8"; # base05 — foreground
    fgLt   = "e8e8e8"; # base06 — light foreground
    white  = "f8f8f8"; # base07 — light background
    red    = "ab4642"; # base08 — errors / deletions
    orange = "dc9656"; # base09 — integers / booleans
    yellow = "f7ca88"; # base0A — classes / search matches
    green  = "a1b56c"; # base0B — strings / success
    cyan   = "86c1b9"; # base0C — support / regex
    blue   = "7cafc2"; # base0D — functions / methods
    purple = "ba8baf"; # base0E — keywords / storage
    brown  = "a16946"; # base0F — deprecated / special
  };
in
{
  programs.zsh = {
    enable = true;

    # ── History ─────────────────────────────────────────────────────────────────
    history = {
      size        = 10000;
      save        = 10000;
      path        = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups  = true;
      ignoreSpace = true;   # lines prefixed with space are not saved
      share       = true;   # share history across all open terminals
    };

    # ── Plugins managed by home-manager ─────────────────────────────────────────
    # autosuggestion: grey completions as you type (accept with → or Ctrl-E)
    autosuggestion.enable    = true;
    # syntaxHighlighting: colour-codes commands while typing
    syntaxHighlighting.enable = true;

    # ── zsh-vi-mode ─────────────────────────────────────────────────────────────
    # Full vi keybindings in zsh. Normal mode with Escape, visual mode with v.
    # See: https://github.com/jeffreytse/zsh-vi-mode
    plugins = [
      {
        name = "zsh-vi-mode";
        src  = pkgs.zsh-vi-mode;
      }
    ];

    # ── Shell init ───────────────────────────────────────────────────────────────
    initContent = ''
      # ── Options ──────────────────────────────────────────────────────────────
      setopt AUTO_CD          # type a dir name to cd into it
      setopt CORRECT          # suggest corrections for mistyped commands
      setopt HIST_VERIFY      # show expanded history cmd before running it
      setopt PROMPT_SUBST     # allow $() and $var in PROMPT (evaluated each draw)
      setopt NO_BEEP          # no terminal bell

      # ── Colours — shell variables with # prefix for use in prompt / styles ───
      # (Nix has already baked the hex values in at build time)
      _c_bg="#${c.bg}"
      _c_cmt="#${c.cmt}"
      _c_fg="#${c.fg}"
      _c_red="#${c.red}"
      _c_yellow="#${c.yellow}"
      _c_green="#${c.green}"
      _c_cyan="#${c.cyan}"
      _c_blue="#${c.blue}"
      _c_purple="#${c.purple}"

      # ── Prompt ───────────────────────────────────────────────────────────────
      # Format: ~/current/dir (branch) ❯
      #   %~          — current directory relative to $HOME
      #   PROMPT_SUBST expands $() at each draw so _git_branch runs live
      #
      # _git_branch prints " (branchname)" when inside a git repo, else nothing.
      _git_branch() {
        local b
        b=$(git branch --show-current 2>/dev/null)
        [[ -n $b ]] && printf " %%F{$_c_cmt}(%s)%%f" "$b"
      }

      # zvm_after_init is a hook called by zsh-vi-mode after its own setup.
      # We use it to restore our prompt and any key bindings that zsh-vi-mode
      # would otherwise override (e.g. Ctrl-R history search).
      #
      # Because zsh-vi-mode defers its init to the first precmd invocation
      # (i.e. before the first prompt is drawn), this function is guaranteed
      # to be defined in time even though plugins are sourced before initContent.
      zvm_after_init() {
        # Dir in blue, optional git branch in comment-grey, prompt char in green
        PROMPT='%F{$_c_blue}%~%f''$(_git_branch) %F{$_c_green}❯%f '
        RPROMPT=""

        # Restore keys that zsh-vi-mode rebinds away from sensible defaults
        bindkey '^R' history-incremental-search-backward
        bindkey '^P' up-line-or-history
        bindkey '^N' down-line-or-history
        bindkey '^E' end-of-line
        bindkey '^A' beginning-of-line
      }

      # Set a prompt for the brief window before zsh-vi-mode's first precmd fires
      # (avoids a blank/default prompt on the very first line)
      PROMPT='%F{$_c_blue}%~%f %F{$_c_green}❯%f '

      # ── Autosuggestion ───────────────────────────────────────────────────────
      # Dim grey — visible but unobtrusive; matches the base16 comment colour
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#${c.cmt}"
      # Try history first, fall back to tab-completion candidates
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)

      # ── Syntax highlighting colours ──────────────────────────────────────────
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[default]="fg=#${c.fg}"
      ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=#${c.red},bold"
      ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=#${c.purple}"
      ZSH_HIGHLIGHT_STYLES[precommand]="fg=#${c.purple}"
      ZSH_HIGHLIGHT_STYLES[builtin]="fg=#${c.blue}"
      ZSH_HIGHLIGHT_STYLES[command]="fg=#${c.green}"
      ZSH_HIGHLIGHT_STYLES[alias]="fg=#${c.green}"
      ZSH_HIGHLIGHT_STYLES[function]="fg=#${c.green}"
      ZSH_HIGHLIGHT_STYLES[path]="fg=#${c.cyan}"
      ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=#${c.cyan}"
      ZSH_HIGHLIGHT_STYLES[globbing]="fg=#${c.yellow}"
      ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=#${c.yellow}"
      ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=#${c.yellow}"
      ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=#${c.yellow}"
      ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=#${c.orange}"
      ZSH_HIGHLIGHT_STYLES[comment]="fg=#${c.cmt}"
      ZSH_HIGHLIGHT_STYLES[redirection]="fg=#${c.fgDark}"
      ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=#${c.fgDark}"
      ZSH_HIGHLIGHT_STYLES[assign]="fg=#${c.fg}"

      # ── Aliases ──────────────────────────────────────────────────────────────
      alias rebuild='sudo nixos-rebuild switch --flake /etc/nixos#leavenworth'
      alias update='cd /etc/nixos && sudo ./scripts/rebuild.sh'
      alias ls='ls --color=auto'
      alias ll='ls -lah --color=auto'
      alias la='ls -A --color=auto'
      alias grep='grep --color=auto'
      alias diff='diff --color=auto'
    '';
  };
}
