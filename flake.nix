{
  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    plugins.url = "github:NixNeovim/NixNeovimPlugins";
  };
  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      nixpkgsArgs = { inherit system; config = { }; };
      nixpkgs = import inputs.stable nixpkgsArgs;
      plugins = inputs.plugins.packages.${system};
      neovim = nixpkgs.neovim.override {
        configure = {
          customRC = import ./vimrc.nix { inherit (nixpkgs) writeText nodejs; };
          packages.myPlugins = let p = nixpkgs.vimPlugins; in {
            start = [
              nixpkgs.vimPlugins.coc-nvim
              plugins.conform-nvim # "stevearc/conform.nvim"
              nixpkgs.vimPlugins.vim-nix
            ];
          };
        };
      };
      editor-cdm = nixpkgs.writeShellApplication {
        name = "editor-cdm";
        runtimeInputs = [ neovim ];
        text = ''
          nvim "$@"
        '';
      };
    in
    rec {
      packages = {
        default = editor-cdm;
        inherit editor-cdm neovim;
      };
    });
}
