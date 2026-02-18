{ config, pkgs, inputs, ... }:

# Zsh colour palette — baked in at build time, no runtime deps.
# Palette: base16-default-dark. Update hex values if you change the scheme.
let
  c = {
    bg     = "181818"; # base00
    bgAlt  = "282828"; # base01
    sel    = "383838"; # base02
    cmt    = "585858"; # base03
    fgDark = "b8b8b8"; # base04
    fg     = "d8d8d8"; # base05
    fgLt   = "e8e8e8"; # base06
    white  = "f8f8f8"; # base07
    red    = "ab4642"; # base08
    orange = "dc9656"; # base09
    yellow = "f7ca88"; # base0A
    green  = "a1b56c"; # base0B
    cyan   = "86c1b9"; # base0C
    blue   = "7cafc2"; # base0D
    purple = "ba8baf"; # base0E
    brown  = "a16946"; # base0F
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
    enable    = true;
    userName  = "lain540";
    userEmail = "261604810+lain540@users.noreply.github.com";
    settings  = { init.defaultBranch = "stable"; pull.rebase = false; };
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
