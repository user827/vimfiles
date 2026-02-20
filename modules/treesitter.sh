install() {
  /usr/bin/nvim --headless "+lua require'nvim-treesitter'.install { 'vim', 'regex', 'lua', 'bash', 'markdown', 'markdown_inline' }" "+quit"
}
