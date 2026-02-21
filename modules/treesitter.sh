install() {
  rustup update stable
  cargo +stable install --locked tree-sitter-cli
  /usr/bin/nvim --headless "+lua require'nvim-treesitter'.install({ 'vim', 'regex', 'lua', 'bash', 'markdown', 'markdown_inline', 'diff', 'latex', 'css', 'html', 'javascript', 'norg', 'scss', 'svelte', 'tsx', 'typst', 'vue'}):wait(300000)" "+quit"
}
