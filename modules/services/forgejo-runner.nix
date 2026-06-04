{
    lib,
    pkgs,
    config,
    ...
}:
with lib;
let
    cfg = config.services.forgejo-runner;
in
{
    options.services.forgejo-runner = {
        enable = mkEnableOption "Forgejo Runner";
        name = mkOption {
            type = types.str;
        };
        url = mkOption {
            type = types.str;
            default = "https://git.abus.lan";
        };
        tokenPath = mkOption {
            type = types.path;
            default = ../../secrets/forgejo-runner-token.age;
        };
        labels = mkOption {
            type = types.listOf types.str;
            default = [
                "node:docker://ghcr.io/abus-sh/node-cert:lts"
            ];
        };
        enableDocker = mkOption {
            type = types.bool;
            default = true;
        };
    };

    config = mkIf cfg.enable {
        services.gitea-actions-runner = {
            package = pkgs.forgejo-runner;
            instances.default = {
                enable = true;
                name = cfg.name;
                url = cfg.url;
                tokenFile = config.age.secrets.forgejo-runner-token.path;
                labels = cfg.labels;
            };
        };
        
        virtualisation.docker.enable = true;

        age.secrets.forgejo-runner-token = {
            file = cfg.tokenPath;
            owner = "root";
            group = "root";
        };
    };
}
