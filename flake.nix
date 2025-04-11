{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    hyprswitch.url = "github:h3rmt/hyprswitch/release";
    #kmonad = {
      #url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
      #inputs.nixpkgs.follows = "nixpkgs";
    #};
    musnix  = { url = "github:musnix/musnix"; };
    niri = {                                   # ← Add this
      url = "github:sodiboo/niri-flake";
      #inputs.nixpkgs.follows = "nixpkgs";      # Optional: share nixpkgs
    };
    xremap-flake.url = "github:xremap/nix-flake";
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, hyprland, nur, ... }: {
  #outputs = { nixpkgs, home-manager, nur, ... }@inputs: {
    nixosConfigurations = {
      py = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          nur.modules.nixos.default
          inputs.niri.nixosModules.niri
          # This adds a nur configuration option.
          # Use `config.nur` for packages like this:
          # ({ config, ... }: {
          #   environment.systemPackages = [ config.nur.repos.mic92.hello-nur ];
          # })
          inputs.xremap-flake.nixosModules.default
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
