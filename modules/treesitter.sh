install() {
  if ! command -v tree-sitter > /dev/null; then
    rustup update stable
    cargo +stable install --locked tree-sitter-cli
  fi
  /usr/bin/nvim --headless "+lua require'nvim-treesitter'.install({ 'bash', 'c', 'diff', 'html', 'javascript', 'jsdoc', 'json', 'jsonc', 'lua', 'luadoc', 'luap', 'markdown', 'markdown_inline', 'printf', 'python', 'query', 'regex', 'toml', 'tsx', 'typescript', 'vim', 'vimdoc', 'xml', 'yaml', 'latex', 'css', 'norg', 'scss', 'svelte', 'typst', 'vue'}):wait(300000)" "+quit"
}
