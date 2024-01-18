{ nodejs, writeText }:
''
  set lbr

  nnoremap ; :

  command Wq wq
  command WQ wq
  command Q q

  set expandtab
  set shiftwidth=2
  set tabstop=2

  let g:coc_node_path = '${nodejs}/bin/node'
  let g:coc_user_config = '${
    writeText "coc.json" (builtins.toJSON {
      "coc.preferences.formatOnSaveFiletypes" = ["css" "markdown"];
    })
  }'

  luafile ${
    writeText "conform.lua" ''
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
''
