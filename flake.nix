{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    #hyprswitch.url = "github:h3rmt/hyprswitch/release";
    #hyprshell.url = "github:H3rmt/hyprswitch?ref=hyprshell";
    hyprshell.url = "github:H3rmt/hyprshell?ref=hyprshell-release";
    hyprshell.inputs.nixpkgs.follows = "nixpkgs";
    #kmonad = {
      #url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
      #inputs.nixpkgs.follows = "nixpkgs";
    #};
    musnix  = { url = "github:musnix/musnix"; };
    xremap-flake.url = "github:xremap/nix-flake";
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, hyprland, hyprshell, nur, ... }: {
  #outputs = { nixpkgs, home-manager, hyprland, hyprshell, nur, ... }@inputs: {
  #outputs = { nixpkgs, home-manager, nur, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          #{ environment.systemPackages = [ hyprshell.packages.x86_64-linux.hyprshell ]; }
          nur.modules.nixos.default
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
            home-manager.extraSpecialArgs = { inherit inputs; }; # hyprshell

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
  };
}
