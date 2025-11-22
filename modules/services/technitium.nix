{ pkgs, lib, ... }:

{
  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
  };

  # Workaround advised by https://github.com/NixOS/nixpkgs/issues/416320#issuecomment-2986237772
  systemd.services.technitium-dns-server.serviceConfig = {
    WorkingDirectory = lib.mkForce null;
    BindPaths = lib.mkForce null;
  };
}
