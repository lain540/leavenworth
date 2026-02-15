{ config, pkgs, ... }:

{
  # Terminal and CLI tools
  environment.systemPackages = with pkgs; [
    # Terminal emulator
    foot
    
    # File manager
    nnn
    
    # Additional CLI utilities
    btop        # Better top
    eza         # Better ls
    bat         # Better cat
    du-dust     # Better du
  ];
}
