#!/bin/sh
# Hardware-free checks. The upstream tests use local simulated peers, not LAN devices.
set -eu
cd "$(dirname "$0")/.."
cargo fmt --all --check
cargo clippy --locked --all-targets -- -D warnings
cargo test --locked

revision=c59b61fdd7cf0b9cfcd3b1257cb87f336e59a48d
source_dir="$PWD/.cache/matter-rust"
if [ ! -d "$source_dir/.git" ]; then
    mkdir -p "$source_dir"
    git -C "$source_dir" init -q
    git -C "$source_dir" remote add origin https://github.com/phunapps/matter-rust.git
    git -C "$source_dir" fetch --depth 1 origin "$revision"
    git -C "$source_dir" checkout --detach FETCH_HEAD
fi
test "$(git -C "$source_dir" rev-parse HEAD)" = "$revision"
test -z "$(git -C "$source_dir" status --porcelain)"
# Keep path-dependent fixture builds out of the user's shared Cargo cache.
export CARGO_TARGET_DIR="$PWD/.cache/matter-target"
cd "$source_dir"
cargo test --locked -p matter-commissioning --features driver --test commission_loopback commission_reaches_done_against_mock_device -- --exact
cargo test --locked -p matter-controller --no-default-features --lib over_loopback
cargo test --locked -p matter-controller --no-default-features --lib response_deadline
cargo test --locked -p matter-controller --no-default-features --lib actor::tests::sibling_subscriptions_survive_each_others_resubscribe -- --exact
