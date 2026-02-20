install() {
  /usr/bin/nvim "+require'nvim-treesitter'.install { 'vim', 'regex', 'lua', 'bash', 'markdown', 'markdown_inline' } | quit"
}
