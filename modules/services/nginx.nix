{
  pkgs,
  lib,
  ...
}:

{
  services.nginx = {
    enable = true;
    virtualHosts.default = {
      locations."/" = {
        return = "404 'Not Found'";
        extraConfig = ''
          default_type text/html;
        '';
      };
      default = true;
    };
  };
}