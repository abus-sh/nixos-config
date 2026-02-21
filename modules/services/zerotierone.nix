{ pkgs, lib, ... }:

{
  services.zerotierone = {
    enable = true;
  };

  # Allow zerotierone as an unfree package
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.strings.getName pkg) [
    "zerotierone"
  ];
}
