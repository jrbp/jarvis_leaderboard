{
  description = "for reproducible ML environments and workflows";

  # We import the latest commit of dream2nix main branch and instruct nix to
  # re-use the nixpkgs revision referenced by dream2nix.
  # This is what dream2nix tests in CI with, though we could use
  # some other recent nixpkgs commit here.
  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    nixpkgs.follows = "dream2nix/nixpkgs";
  };

  outputs = {
    self,
    dream2nix,
    nixpkgs,
  }: let
    # A helper that helps us define the attributes below for
    # all systems we care about.
    eachSystem = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  in {
    packages = eachSystem (system:
      dream2nix.lib.importPackages {
        # All packages defined in ./jarvis_leaderboard/contributions/<name> are automatically added to the flake outputs
        # e.g., 'jarvis_leaderboard/contributions/hello/default.nix' becomes '.#hello'
        projectRoot = ./.;
        projectRootFile = "flake.nix";
        packagesDir = ./jarvis_leaderboard/contributions;
        packageSets.nixpkgs = nixpkgs.legacyPackages.${system};
      });
    # TODO: how to handle dev shells for each package
    devShells = eachSystem (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        # inherit from the dream2nix generated dev shel
        inputsFrom = [self.packages.${system}.ElemNet1-reprod0.devShell];
        # add extra packages
        packages = [
          self.packages.${system}.ElemNet1-reprod0.config.deps.python.pkgs.ipython
        ];
      };
    });
  };
}
