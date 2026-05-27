{
  pkgs,
  lib,
  ...
}:

{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
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

  # Allow HTTP and HTTPS
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}