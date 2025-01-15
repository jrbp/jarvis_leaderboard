{
  config,
  lib,
  dream2nix,
  ...
}: {
  imports = [
    dream2nix.modules.dream2nix.WIP-python-pdm
  ];

  deps = {nixpkgs, ...}: {
    python = nixpkgs.python310;
    libtensorflow = nixpkgs.libtensorflow; # hmmm
  };

  mkDerivation = {
    src = ./src;
  };
  pdm = {
    lockfile = ./pdm.lock;
    pyproject = ./pyproject.toml;
    useUvResolver = true;
  };

  buildPythonPackage = {
    pythonImportsCheck = [
      "jarvis"
    ];
  };

  overrides = {
    sklearn.env.SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL = "True";
    tensorflow-io-gcs-filesystem = {
      # these both build, but I'm not confident either is "correct"
      #env.autoPatchelfIgnoreMissingDeps = ["libtensorflow_framework.so.2"];
      mkDerivation.buildInputs = [
        config.deps.libtensorflow
      ];
    };
  };
}
