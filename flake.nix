{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      imports = [
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.pre-commit-hooks-nix.flakeModule
      ];
      perSystem = { pkgs, config, ... }:
        {
          treefmt.config = {
            inherit (config.flake-root) projectRootFile;
            package = pkgs.treefmt;
            programs = {
              nixpkgs-fmt.enable = true;
            };
          };
          pre-commit.settings.hooks = {
            treefmt.enable = true;
            treefmt.package = config.treefmt.build.wrapper;
          };
          devShells.default =
            let
              treefmt = config.treefmt.build.wrapper;
              treefmt-programs = builtins.attrValues config.treefmt.build.programs;
              tools = [
                treefmt
                pkgs.fortune
                pkgs.cowsay
                pkgs.lolcat
              ] ++ treefmt-programs;
              welcomeShellHook = ''
                fortune | cowsay | lolcat
              '';
            in
            pkgs.mkShell {
              nativeBuildInputs = tools;
              shellHook = ''
                ${config.pre-commit.installationScript}
                ${welcomeShellHook}
              '';
            };
        };
    };
}
