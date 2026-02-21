install() {
  cd vim/pack/light/opt/blink.cmp/
  [ -d target ] || cargo build --release --target-dir target
  rustup update
  cargo install --locked tree-sitter-cli
}
