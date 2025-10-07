{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  extraGroups = [
    "wheel"
  ] ++ ifTheyExist [
    "dialout"
    "docker"
    "lp"
    "networkmanager"
    "scanner"
    "vboxusers"
  ];
in
{
  users.users.abus = {
    isNormalUser = true;
    description = "Abus";
    inherit extraGroups;
  };
}
