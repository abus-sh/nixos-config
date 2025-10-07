{ config, lib, pkgs, ... }:

{
  users.users.deploy-rs = {
    isSystemUser = true;
    description = "deploy-rs system account";
    group = "deploy-rs";
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXIt2CN5GRiZ949+rmt48J8I57y9VpEEGTTllXBg8Pa abus@abusmachine"
    ];
  };

  users.groups.deploy-rs = {};

  security.sudo.extraRules = [
    {
      users = [ "deploy-rs" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nix.settings.trusted-users = [ "deploy-rs" ];
}
