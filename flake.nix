{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      ];
      perSystem = { pkgs, ... }:
        {
          devShells.default =
            let
              tools = [
                pkgs.fortune
                pkgs.cowsay
                pkgs.lolcat
              ];
              welcomeShellHook = ''
                fortune | cowsay | lolcat
              '';
            in
            pkgs.mkShell {
              nativeBuildInputs = tools;
              shellHook = ''
                ${welcomeShellHook}
              '';
            };
        };
    };
}
