self: super:

{
  chooseFoundry = super.callPackage ./choose-foundry/package.nix { };

  obs-studio-plugins = super.obs-studio-plugins // {
    obs-livesplit-one = super.obs-studio-plugins.obs-livesplit-one.overrideAttrs (old: rec {
      version = "0.5.1";

      src = super.fetchFromGitHub {
        owner = "AlexKnauth";
        repo = "obs-livesplit-one";
        rev = "018bf332e5a180aff55d9ce606645a1e5e8aad1d";
        sha256 = "sha256-yHAmWpte2F0yhmKJ3q0xFQJbfLCnqeOMq02bSkN1f+g=";
      };

      cargoDeps = old.cargoDeps.overrideAttrs (old: {
        vendorStaging = old.vendorStaging.overrideAttrs {
          inherit src;
          outputHash = "sha256-KLkjxuAuVk9awewSKRqgV+UzvOAAfLYKMA0+YqdBrkE=";
        };
      });
    });
  };
}
