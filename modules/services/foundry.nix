{ pkgs, ... }:

{
  users.users.foundry = {
    isSystemUser = true;
    description = "foundry system account";
    group = "foundry";
    home = "/var/foundry";
    createHome = true;
    linger = true;
    packages = with pkgs; [
      nodejs_22
      pm2
    ];
  };

  users.groups.foundry = {};

  systemd.services.foundry = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    description = "Foundry VTT Service";
    serviceConfig = {
      Type = "simple";
      # This requires that the Foundry VTT manually be placed in ~foundry/foundry and
      # ~foundry/foundryuserdata be created.
      ExecStart = ''/etc/profiles/per-user/foundry/bin/node /var/foundry/foundry/resources/app/main.js --dataPath=/var/foundry/foundryuserdata'';
      User="foundry";
    };
  };
}
