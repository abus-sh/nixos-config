{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };
  outputs = { self, nixpkgs }: {
    nixosConfigurations.abusmachine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./machines/abusmachine/configuration.nix ];
    };

    nixosConfigurations.nixosvm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./machines/nixosvm/configuration.nix ];
    };
  };
}