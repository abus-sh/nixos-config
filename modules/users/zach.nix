{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.zach = {
    isNormalUser = true;
    description = "Zach";
    packages = with pkgs; [
      chooseFoundry
    ];
    openssh.authorizedKeys.keys = [
      ''command="sudo ${pkgs.chooseFoundry}/bin/choose-foundry" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGsPkT9zDM59uWnSHOhc7KLIJ15SvsIuy4DrbUVk0MCE zach''
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "zach" ];
      commands = [
        {
          command = "${pkgs.chooseFoundry}/bin/choose-foundry";
          options = [
            "NOSETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
}
