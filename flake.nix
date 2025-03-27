{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprswitch.url = "github:h3rmt/hyprswitch/release";
    #kmonad = {
      #url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
      #inputs.nixpkgs.follows = "nixpkgs";
    #};
    musnix  = { url = "github:musnix/musnix"; };
    #xremap-flake.url = "github:xremap/nix-flake";
  };

  outputs = inputs@{ nixpkgs, home-manager, nur, ... }: {
  #outputs = { nixpkgs, home-manager, nur, ... }@inputs: {
    nixosConfigurations = {
      py = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          nur.modules.nixos.default
          # This adds a nur configuration option.
          # Use `config.nur` for packages like this:
          # ({ config, ... }: {
          #   environment.systemPackages = [ config.nur.repos.mic92.hello-nur ];
          # })
          #inputs.xremap-flake.nixosModules.default
          #kmonad.nixosModules.default
          inputs.musnix.nixosModules.musnix

          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = false;
            home-manager.useUserPackages = true;
            home-manager.users.py = import ./home.nix;
            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
  };
}
