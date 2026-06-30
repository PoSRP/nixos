{
  description = "NixOS Hyprland Desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      username = "sr";

      homeManagerModule = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-bak";
        home-manager.extraSpecialArgs = { inherit username; };
        home-manager.users.${username} = import ./home/user.nix;
      };

      specialArgs = { inherit username; };
    in {
      nixosConfigurations.qemu-desktop = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/qemu-desktop/configuration.nix
          home-manager.nixosModules.home-manager
          homeManagerModule
        ];
      };

      nixosConfigurations.thinkpad-w540 = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/thinkpad-w540/configuration.nix
          home-manager.nixosModules.home-manager
          homeManagerModule
        ];
      };

      nixosConfigurations.thinkpad-x13-gen1 = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          ./hosts/thinkpad-x13-gen1/configuration.nix
          home-manager.nixosModules.home-manager
          homeManagerModule
        ];
      };

      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ({ pkgs, ... }:
          let
            systems = {
              thinkpad-x13-gen1 = self.nixosConfigurations.thinkpad-x13-gen1.config.system.build.toplevel;
              thinkpad-w540     = self.nixosConfigurations.thinkpad-w540.config.system.build.toplevel;
            };
          in {
            isoImage.contents = [
              { source = self; target = "/config"; }
              { source = pkgs.writeText "username" username; target = "/username"; }
            ] ++ nixpkgs.lib.mapAttrsToList (name: toplevel: {
              source = pkgs.writeText name "${toplevel}";
              target = "/systems/${name}";
            }) systems;

            isoImage.storeContents = nixpkgs.lib.attrValues systems;
          })
        ];
      };
    };
}
