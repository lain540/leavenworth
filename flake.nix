{
  description = "Leavenworth NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nvf - declarative neovim configuration
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nvf, musnix, ... }@inputs:
  let
    system = "x86_64-linux";

    # ── Custom packages overlay ───────────────────────────────────────────────
    # Adds locally-defined packages (pkgs/*) into the nixpkgs package set so
    # they can be referenced as pkgs.voxengo-span anywhere in the config.
    customOverlay = final: prev: {
      voxengo-span = final.callPackage ./pkgs/voxengo-span/default.nix {};
    };

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ customOverlay ];
    };
  in
  {
    nixosConfigurations.leavenworth = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # Apply the overlay system-wide so nixpkgs.pkgs also has our custom pkgs
        { nixpkgs.overlays = [ customOverlay ]; }
        ./configuration.nix
        musnix.nixosModules.musnix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.svea = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.sharedModules = [
            nvf.homeManagerModules.default
          ];
        }
      ];
    };
  };
}
