{
  inputs = {
    stable.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    plugins.url = "github:NixNeovim/NixNeovimPlugins";
  };
  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      nixpkgsArgs = { inherit system; config = { }; };
      nixpkgs = import inputs.stable nixpkgsArgs;
      plugins = inputs.plugins.packages.${system};
    in
    rec {
      packages.default = nixpkgs.neovim.override {
        configure = {

          customRC = ''
            set lbr

            nnoremap ; :

            command Wq wq
            command WQ wq
            command Q q

            set expandtab
            set shiftwidth=2
            set tabstop=2

            let g:coc_node_path = '${nixpkgs.nodejs}/bin/node'
            let g:coc_user_config = '${
              nixpkgs.writeText "coc.json" (builtins.toJSON {
                "coc.preferences.formatOnSaveFiletypes" = ["css" "markdown"];
              })
            }'

            luafile ${
              nixpkgs.writeText "conform.lua" ''
                require("conform").setup({
                  format_on_save = {
                    lsp_fallback = true,
                    timeout_ms = 500,
                  },
                  formatters_by_ft = {
                    nix = { "nixpkgs_fmt" },
                  },
                })
              ''
            }
          '';
          packages.myPlugins = let p = nixpkgs.vimPlugins; in {
            start = [
              nixpkgs.vimPlugins.coc-nvim
              plugins.conform-nvim # "stevearc/conform.nvim"
              nixpkgs.vimPlugins.vim-nix
            ];
          };
        };
      };
    });
}
