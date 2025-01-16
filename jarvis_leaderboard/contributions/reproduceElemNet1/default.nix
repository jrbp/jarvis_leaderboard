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
    runElemNet1Patched = nixpkgs.runCommand "runElemNet1Patched" {} ''
        mkdir -p $out
        patch -o $out/run.py ${../ElemNet1/run.py} ${./runpy.patch}
      '';
  };
  mkDerivation = {
    src = ./.;
    # following is mainly needed because of the ipython magic commands
    # though I'm currently using it to tell the script where the benchmarks data is
    installPhase =
      ''
      mkdir -p $out/bin
      cat > $out/bin/reproduceElemNet1 <<EOF
      #!/bin/sh
      ${config.public.pyEnv}/bin/ipython ${config.deps.runElemNet1Patched}/run.py ${../../benchmarks}
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
    tensorflow-io-gcs-filesystem.env.autoPatchelfIgnoreMissingDeps = ["libtensorflow_framework.so.2"];
  };
}
