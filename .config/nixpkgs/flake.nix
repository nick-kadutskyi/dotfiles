# To install packages to the user environment, run:
#   nix profile install $HOME/.config/nixpkgs
# Or if you symlinked the flake to ~/.config/nixpkgs, you can run:
#   nix profile install "$(readlink -f $HOME/.config/nixpkgs)"
# To update the environment after changing this file or inputs, run:
#   nix profile upgrade ".*"
# To build nix-darwin system configurations first time, run:
#   nix run nix-darwin -- switch --flake "$(readlink -f ~/.config/nixpkgs)"
# To update nix-darwin system configurations after changing, run in the flake dir:
#   darwin-rebuild switch --flake . 

{
  description = "Default user environment packages";
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, flake-utils, nix-darwin }@inputs:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        defaultPackages = {
          inherit (pkgs)
          # Basic terminal tools
            gnused # gnused on all platforms
            # Utilities
            bat # colorized cat
            # Development
            devenv# development environment
            # Nix
            nixfmt-classic # format nix files
            nixpkgs-fmt # format nixpkgs files
          ;
        };
        linuxPackages = with pkgs; { inherit git; };
        darwinPackages = with pkgs; { inherit ; };

        userPackages = defaultPackages
          // (if (pkgs.lib.strings.hasInfix "linux" system) then
            linuxPackages
          else
            { }) // (if (pkgs.lib.strings.hasInfix "darwin" system) then
              darwinPackages
            else
              { });

        packageListString = pkgs.lib.concatMapStringsSep "\n" (x: "${x}")
          (builtins.attrValues userPackages);
      in {
        packages.default = pkgs.buildEnv {
          name = "nick-default-packages";
          paths = builtins.attrValues userPackages;
        };
      })) // {
        # darwin system config here
        darwinConfigurations = {
          "Nicks-MacBook-Air" = nix-darwin.lib.darwinSystem {
            inherit inputs;
            modules = [ ./hosts/mac-default/configuration.nix ]
              ++ (if true then [ ./hosts/mac-default/dnsmasq.nix ] else [])
              ++ (if true then [ ./hosts/mac-default/httpd.nix ] else [])
              ++ [];
          };
          "Nicks-Mac-mini" = nix-darwin.lib.darwinSystem {
            inherit inputs;
            modules = [ ./hosts/mac-default/configuration.nix ]
              ++ (if true then [ ./hosts/mac-default/dnsmasq.nix ] else [])
              ++ (if true then [ ./hosts/mac-default/httpd.nix ] else [])
              ++ [];
          };
        };
        # nixos config here
      };
}
