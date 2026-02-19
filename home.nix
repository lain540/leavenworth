{ config, pkgs, inputs, ... }:

# Map stylix base16 colors to readable names for use in zsh/prompt config.
# Changing stylix.base16Scheme in configuration.nix updates these automatically.
let
  c = with config.lib.stylix.colors; {
    bg     = base00;
    bgAlt  = base01;
    sel    = base02;
    cmt    = base03;
    fgDark = base04;
    fg     = base05;
    fgLt   = base06;
    white  = base07;
    red    = base08;
    orange = base09;
    yellow = base0A;
    green  = base0B;
    cyan   = base0C;
    blue   = base0D;
    purple = base0E;
    brown  = base0F;
  };
in
{
  imports = [
    ./modules/home-manager/desktop.nix
    ./modules/home-manager/applications.nix
  ];

  home.username      = "svea";
  home.homeDirectory = "/home/svea";
  home.stateVersion  = "25.11";

  programs.home-manager.enable = true;

  # ── Git ───────────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name   = "lain540";
      user.email  = "261604810+lain540@users.noreply.github.com";
      init.defaultBranch = "stable";
      pull.rebase = false;
    };
  };

  # ── XDG ───────────────────────────────────────────────────────────────────────
  xdg.userDirs = { enable = true; createDirectories = true; };

  # ── Shell — Zsh ───────────────────────────────────────────────────────────────
  # autosuggestions: grey completions (accept with → or Ctrl-E)
  # syntaxHighlighting: colour-codes commands while typing
  # zsh-vi-mode: Escape for normal mode, v for visual
  programs.zsh = {
    enable = true;

    history = {
      size        = 10000;
      save        = 10000;
      path        = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups  = true;
      ignoreSpace = true;
      share       = true;
    };

    autosuggestion.enable     = true;
    syntaxHighlighting.enable = true;
    plugins = [{ name = "zsh-vi-mode"; src = pkgs.zsh-vi-mode; }];

    initContent = ''
      setopt AUTO_CD CORRECT HIST_VERIFY PROMPT_SUBST NO_BEEP

      # ── Prompt — ~/dir (branch) ❯ ───────────────────────────────────────────
      _git_branch() {
        local b; b=$(git branch --show-current 2>/dev/null)
        [[ -n $b ]] && printf " %%F{#${c.cmt}}(%s)%%f" "$b"
      }

      # zvm_after_init restores prompt + keybinds after zsh-vi-mode overwrites them
      zvm_after_init() {
        PROMPT='%F{#${c.blue}}%~%f$(_git_branch) %F{#${c.green}}❯%f '
        RPROMPT=""
        bindkey '^R' history-incremental-search-backward
        bindkey '^P' up-line-or-history
        bindkey '^N' down-line-or-history
        bindkey '^E' end-of-line
        bindkey '^A' beginning-of-line
      }
      PROMPT='%F{#${c.blue}}%~%f %F{#${c.green}}❯%f '

      # ── Autosuggestions ─────────────────────────────────────────────────────
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#${c.cmt}"
      ZSH_AUTOSUGGEST_STRATEGY=(history completion)

      # ── Syntax highlighting ─────────────────────────────────────────────────
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
    '';
  };

  # ── Packages ──────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    ripgrep fd fzf
  ];
}
