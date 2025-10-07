{ config, lib, pkgs, ... }:

{
  users.users.gato = {
    isNormalUser = true;
    description = "Gato";
  };
}
