{
  description = "Leavenworth NixOS Configuration";

  inputs = {
    nixpkgs.url  = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nvf, musnix, stylix, ... }@inputs: {
    nixosConfigurations.leavenworth = nixpkgs.lib.nixosSystem {
      system      = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        musnix.nixosModules.musnix
        stylix.nixosModules.stylix         # also injects stylix into home-manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs       = true;
          home-manager.useUserPackages     = true;
          home-manager.users.svea          = import ./home.nix;
          home-manager.extraSpecialArgs    = { inherit inputs; };
          home-manager.backupFileExtension = "bak"; # rename conflicts instead of aborting
          home-manager.sharedModules       = [ nvf.homeManagerModules.default ];
        }
      ];
    };
  };
}
