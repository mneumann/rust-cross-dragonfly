RUST_MANIFEST=/usr/local/lib/rustlib/manifest
CARGO_MANIFEST=/usr/local/lib/cargo/manifest
FILE=rust-0.12.0-pre-dragonfly.tar 
tar cvf ${FILE} ${RUST_MANIFEST} `cat ${RUST_MANIFEST}` \
    ${CARGO_MANIFEST} `cat ${CARGO_MANIFEST}`
bzip2 -9 ${FILE} 
sha1 ${FILE}.bz2
