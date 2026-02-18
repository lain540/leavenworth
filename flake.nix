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

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # stylix - system-wide base16 theming
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nvf, musnix, stylix, ... }@inputs: {
    nixosConfigurations.leavenworth = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        musnix.nixosModules.musnix
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs    = true;
          home-manager.useUserPackages  = true;
          home-manager.users.svea       = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
          # When home-manager finds a file it wants to manage that already exists
          # on disk (e.g. ~/.librewolf/profiles.ini, ~/.config/mimeapps.list),
          # rename the existing file with this extension instead of aborting.
          # After a successful rebuild you can delete the .bak files safely.
          home-manager.backupFileExtension = "bak";
          home-manager.sharedModules    = [
            nvf.homeManagerModules.default
            # stylix.homeManagerModules.stylix is intentionally absent here —
            # stylix.nixosModules.stylix (above) already injects the home-manager
            # module for every user automatically. Adding it again causes:
            # "stylix.base16 is read-only, set multiple times"
          ];
        }
      ];
    };
  };
}
