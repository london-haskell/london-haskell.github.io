# raehik's copy-paste Nix flake template, bit messy
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
  };

  outputs = inputs:
  let
    defDevShell = compiler: {
      mkShellArgs.name = "${compiler}";
      hoogle = false;
      tools = _: {
        haskell-language-server = null;
        hlint = null;
        ghcid = null;
      };
    };
  in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule ];
      perSystem = { self', pkgs, config, ... }: {
        packages.default  = self'.packages.ghc912-london-haskell-intro;
        devShells.default = self'.devShells.ghc912;
        haskellProjects.ghc914 = {
          basePackages = pkgs.haskell.packages.ghc914;
          settings.network.check = false;
          settings.unicode-data.check = false;
          devShell = {
            mkShellArgs.name = "ghc914";
            hoogle = false;
            tools = _: {
              haskell-language-server = null;
              hlint = null;
              ghcid = null;
              # 2026-09-14: not built by Nixpkgs & takes ages, just use prebuilt
              cabal-install = pkgs.cabal-install;
            };
          };
        };
        haskellProjects.ghc912 = {
          basePackages = pkgs.haskell.packages.ghc912;
          settings.network.check = false;
          settings.unicode-data.check = false;
          devShell = {
            mkShellArgs.name = "ghc914";
            hoogle = false;
            tools = _: {
              haskell-language-server = null;
              hlint = null;
              ghcid = null;
              # 2026-09-14: not built by Nixpkgs & takes ages, just use prebuilt
              cabal-install = pkgs.cabal-install;
            };
          };
        };
        haskellProjects.ghc910 = {
          basePackages = pkgs.haskell.packages.ghc910;
          devShell = defDevShell "ghc910";
        };
      };
    };
}
