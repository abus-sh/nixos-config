{
  makeWrapper,
  runCommand,
}:

let
  # Your external shell script.
  src = ./choose-foundry.sh;
  binName = "choose-foundry";
in
runCommand "${binName}"
  {
    pname = "${binName}";
    version = "v0.1.0";

    nativeBuildInputs = [ makeWrapper ];
    meta = {
      description = "Swap between Foundry running as a systemd service and a Docker container.";
      mainProgram = "${binName}";
    };
  }
  ''
    mkdir -p $out/bin
    install -m +x ${src} $out/bin/${binName}

    wrapProgram $out/bin/${binName}
  ''