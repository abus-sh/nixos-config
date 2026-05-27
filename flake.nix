{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    deploy-rs.url = "github:serokell/deploy-rs";
    agenix.url = "github:ryantm/agenix";
  };
  outputs = { self, nixpkgs, deploy-rs, agenix }: {
    nixosConfigurations.abusmachine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./machines/abusmachine/configuration.nix
        agenix.nixosModules.default
      ];
    };

    nixosConfigurations.artemis = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./machines/artemis/configuration.nix
        agenix.nixosModules.default
      ];
    };

    nixosConfigurations.boreas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./machines/boreas/configuration.nix
        agenix.nixosModules.default
      ];
    };

    nixosConfigurations.nixosvm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./machines/nixosvm/configuration.nix
        agenix.nixosModules.default
      ];
    };

    deploy.nodes.artemis = {
      hostname = "artemis";
      profiles.system = {
        sshUser = "deploy-rs";
        user = "root";
        path = deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.artemis;
      };
    };

    deploy.nodes.boreas = {
      hostname = "boreas";
      profiles.system = {
        sshUser = "deploy-rs";
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.boreas;
      };
    };

    deploy.nodes.nixosvm = {
      hostname = "nixosvm";
      profiles.system = {
        sshUser = "deploy-rs";
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixosvm;
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}