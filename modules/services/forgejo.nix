{
  lib,
  pkgs,
  config,
  ...
}:
let
  forgeAddr = "127.0.0.1";
  forgePort = 3000;
  forgeDomain = "git.abus.lan";
in
{
  services.forgejo = {
    enable = true;
    database.type = "postgres";

    # Enable Git LFS
    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = forgeDomain;
        ROOT_URL = "https://${forgeDomain}/";
        HTTP_ADDR = forgeAddr;
        HTTP_PORT = forgePort;
      };

      # Disallow registration
      service.DISABLE_REGISTRATION = true;
    };
  };

  age.secrets.forgeCert = {
    file = ../../secrets/git.abus.lan.cert.age;
    owner = "nginx";
    group = "nginx";
  };
  age.secrets.forgeKey = {
    file = ../../secrets/git.abus.lan.key.age;
    owner = "nginx";
    group = "nginx";
  };

  services.nginx.virtualHosts."git.abus.lan" = {
    locations."/" = {
      proxyPass = "http://${forgeAddr}:${toString forgePort}";
    };

    # HTTPS
    forceSSL = true;
    sslCertificate = config.age.secrets.forgeCert.path;
    sslCertificateKey = config.age.secrets.forgeKey.path;
  };
}