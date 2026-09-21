{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalattrs: {
  pname = "gencode";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "abus-sh";
    repo = "gencode";
    rev = "479b168dc571137d59f434799446e2e85d5cef72";
    hash = "sha256-QDtk+XeNS4QNj4NrX8a7n0EQD96v1ltEr3QiPQ0+pok=";
  };

  cargoHash = "sha256-6S5ZfQZWJBAQkZKZnBtHwCk1V1HNARHe0ohQW/Xu2/Q=";

  meta = {
    description = "Utility to generate random email addresses";
    homepage = "https://github.com/abus-sh/gencode";
    license = with lib.licenses; [
      asl20
      mit
    ];
  };
})
