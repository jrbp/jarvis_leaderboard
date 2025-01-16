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
    src = ./.;
    # following is a bad hack as the ipython magics only run when started with ipython
    installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/reproduceElemNet1 <<EOF
      #!/bin/sh
      ${config.public.pyEnv}/bin/ipython ${./src/run.py}
      EOF
      chmod +x $out/bin/reproduceElemNet1
    '';
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
