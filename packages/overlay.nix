self: super:

{
  chooseFoundry = super.callPackage ./choose-foundry/package.nix { };

  obs-studio-plugins = super.obs-studio-plugins // {
    obs-livesplit-one = super.obs-studio-plugins.obs-livesplit-one.overrideAttrs (old: rec {
      version = "0.5.1";

      src = super.fetchFromGitHub {
        owner = "LiveSplit";
        repo = "obs-livesplit-one";
        rev = "a5172a46186d95d50b5bc28efe4e331ea5d1091c";
        sha256 = "sha256-aU/orE1k6oGzJGU/gFDk9QzcS2QfgvfAUskS5ghftwM=";
      };

      cargoDeps = old.cargoDeps.overrideAttrs (old: {
        vendorStaging = old.vendorStaging.overrideAttrs {
          inherit src;
          outputHash = "sha256-aUtOAzBOdOWJhgS6SFzxbJZgM7skr/JOUzeAh2RJ8Es=";
        };
      });
    });
  };
}
