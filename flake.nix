{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    deploy-rs.url = "github:serokell/deploy-rs";
  };
  outputs = { self, nixpkgs, deploy-rs }: {
    nixosConfigurations.abusmachine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./machines/abusmachine/configuration.nix ];
    };

    nixosConfigurations.nixosvm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./machines/nixosvm/configuration.nix ];
    };

    deploy.nodes.nixosvm = {
      hostname = "nixosvm";
      profiles.system = {
        profiles.system = {
          sshUser = "abus";
          user = "root";
          interactiveSudo = true;
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixosvm;
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}