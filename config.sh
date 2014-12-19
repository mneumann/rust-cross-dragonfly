BRANCH=dragonfly-fixes2
REPO=https://github.com/mneumann/rust.git

if [ `uname -s` = "DragonFly" ]; then
  FETCH="fetch --no-verify-peer"
else
  FETCH=wget
fi


get_and_extract_nightly() {
  ${FETCH} https://static.rust-lang.org/dist/rust-nightly.tar.gz
  tar xvzf rust-nightly.tar.gz
}
