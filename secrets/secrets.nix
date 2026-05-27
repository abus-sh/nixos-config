let
  abus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEc9FGYBcOnVc/q0YfaS/CCDJXf1Se6dSswZDl67kyBP";
  users = [
    abus
  ];

  artemis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuYjqZKmwoow1vB9EHQE3UoEyCEJRlbHiEwbgE8mvnR";
  boreas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK4OVO2P010PkpIQXwh511UUuAdggwd/k4snjxeo4JWQ";
  nixosvm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHSzouiTkUJl7owycM0uq6ysGxI+MzjShCltpokSceLS";
  systems = [
    nixosvm
  ];
in
{
  "git.abus.lan.key.age".publicKeys = [
    abus
    nixosvm
  ];
  "git.abus.lan.cert.age".publicKeys = [
    abus
    nixosvm
  ];
}