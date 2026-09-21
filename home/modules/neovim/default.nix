{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      flash-nvim
      nvim-lspconfig
      nvim-surround
      nvim-tree-lua
      nvim-web-devicons
      telescope-nvim
      (nvim-treesitter.withPlugins (p: [ p.python ]))
    ];

    extraPackages = with pkgs; [
      basedpyright
      ripgrep
    ];

    initLua = builtins.readFile ./init.lua;
  };
}
