#!/usr/bin/env bash
# Build the GitHub Pages site into $1 (default _site): the play page plus the sample
# games fetched from their upstream open-source repos (MIT), each pinned to a commit,
# with its LICENSE beside it. Nothing comes from the Kaggle dataset (data/).
# Cavebots is compiled to WebAssembly when Go is on PATH (CI uses Go 1.20.8, the
# version the published build used); without Go it is left out.
set -euo pipefail
cd "$(dirname "$0")/.."
OUT="$(mkdir -p "${1:-_site}" && cd "${1:-_site}" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fetch() {  # fetch <owner/repo> <sha> <dir>: the repo's files at that commit
  mkdir -p "$3"
  curl -fsSL "https://codeload.github.com/$1/tar.gz/$2" | tar -xz -C "$3" --strip-components=1
}

mkdir -p "$OUT/games"
cp -R site/index.html site/play.html site/games.json site/screenshots "$OUT/"

# Off Line (gllms/off-line): plain JavaScript, served from src/, with our fixed-seed course
# patch (site/patches/off_line_fixed_seed.patch: every attempt meets the same squares)
fetch gllms/off-line fa1636eda233cdb0bcd813e065448832477f9a0d "$WORK/off_line"
mkdir -p "$OUT/games/off_line"
cp -R "$WORK/off_line/src/." "$OUT/games/off_line/"
patch -s -d "$OUT/games/off_line" -p2 < site/patches/off_line_fixed_seed.patch
cp "$WORK/off_line/LICENSE" "$OUT/games/off_line/LICENSE"

# Asteroid Capitalist (Sidaroth/Asteroid.Capitalist): the author's own release build
fetch Sidaroth/Asteroid.Capitalist f86d05e84ad84edff49251f5b3e8fdfaefdfc09a "$WORK/asteroid_capitalist"
curl -fsSL -o "$WORK/ac.zip" https://github.com/Sidaroth/Asteroid.Capitalist/releases/download/1.1/itch-bundle.zip
unzip -q "$WORK/ac.zip" -d "$WORK/ac"
mkdir -p "$OUT/games/asteroid_capitalist"
cp -R "$WORK/ac/dist/." "$OUT/games/asteroid_capitalist/"
cp "$WORK/asteroid_capitalist/LICENSE" "$OUT/games/asteroid_capitalist/LICENSE"

# Cavebots (quasilyte/cavebots-game): Go + Ebitengine, built as its Makefile's wasm target
fetch quasilyte/cavebots-game 15fb5980fb550dc7031a613918610aa8c91e46fe "$WORK/cavebots"
if command -v go >/dev/null; then
  (cd "$WORK/cavebots" && GOARCH=wasm GOOS=js go build -ldflags="-s -w" -trimpath -o _web/main.wasm ./cmd/game)
  mkdir -p "$OUT/games/cavebots"
  cp "$WORK/cavebots/_web/"{index.html,wasm_exec.js,main.wasm} "$OUT/games/cavebots/"
  cp "$WORK/cavebots/LICENSE" "$OUT/games/cavebots/LICENSE"
else
  echo "go not found: cavebots left out" >&2
fi

# Blarglike (alexandersshen/blarglike): a GameMaker project; its HTML5 export needs a
# signed-in GameMaker account, so it is built locally and committed (site/vendor/blarglike/BUILD.md)
mkdir -p "$OUT/games/blarglike"
cp -R site/vendor/blarglike/. "$OUT/games/blarglike/"

echo "built $OUT"
