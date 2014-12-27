BRANCH=dragonfly-fixes2
REPO=https://github.com/mneumann/rust.git

get_and_extract_nightly() {
  wget https://static.rust-lang.org/dist/rust-nightly.tar.gz
  tar xvzf rust-nightly.tar.gz
}
