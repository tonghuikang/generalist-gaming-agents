# How the Pages games are reproduced

The site (this repo's GitHub Pages) plays the four public sample games of
Kaggle's Generalist Gaming Agent competition. None of its game files come from the competition dataset
(`data/`): the competition rules (section 4b, Data Security) forbid publishing Competition Data to
non-participants. Instead each game is rebuilt from its authors' own open-source repository, all MIT
licensed, pinned to a commit, with the LICENSE served beside the game.

## Per game

| Game | Upstream | Pinned commit | How it is built |
|---|---|---|---|
| Asteroid Capitalist | [Sidaroth/Asteroid.Capitalist](https://github.com/Sidaroth/Asteroid.Capitalist) | `f86d05e` | The authors' own release build: `itch-bundle.zip` from release 1.1, `dist/` served as is |
| Cavebots | [quasilyte/cavebots-game](https://github.com/quasilyte/cavebots-game) | `15fb598` | Compiled in CI with Go 1.20.8 (the version the competition's build used), as the repo's Makefile `wasm` target: `GOARCH=wasm GOOS=js go build -ldflags="-s -w" -trimpath -o _web/main.wasm ./cmd/game`, served with `_web/index.html` and `_web/wasm_exec.js` |
| Off Line | [gllms/off-line](https://github.com/gllms/off-line) | `fa1636e` | Plain JavaScript: the repo's `src/`, with one patch of ours, `patches/off_line_fixed_seed.patch` (below) |
| Blarglike | [alexandersshen/blarglike](https://github.com/alexandersshen/blarglike) | `b78b60d` | GameMaker HTML5 export, built locally and committed under `vendor/blarglike/` (see below) |

## Off Line's fixed-seed patch

Upstream places every square with `Math.random`, so each attempt meets a different course.
`patches/off_line_fixed_seed.patch` (applied by `build.sh`) gives the squares their own seeded generator
(mulberry32, seed 13) in place of all 16 `g.randomInt` calls, re-seeds it at the start of every attempt in
`reset()`, and routes the first Space press through `reset()` too, so every attempt, on every page load,
starts with the same squares. Particles and sounds still use `Math.random`. The course within an attempt
still depends on play (a square is re-placed when it is collected or falls off the bottom), as in the
competition's build, which made the same kind of change with its own generator and seed.

## Build and deploy

`site/build.sh [OUT]` assembles the site (default `_site`): it copies `index.html` and `games.json`, fetches
each repo at its pinned commit from codeload.github.com, builds or extracts the game into `games/<id>/`
and copies its LICENSE there. Without Go on PATH, Cavebots is left out (fine for local checks).

`.github/workflows/pages.yml` runs on every push to `master`: it checks out the repo, installs Go 1.20.8,
runs `site/build.sh _site` and deploys `_site` with GitHub Pages (Pages source: GitHub Actions).

To preview locally: `site/build.sh runs/site`, then serve `runs/site` with any static server, e.g.
`python3 -m http.server -d runs/site`.

## Blarglike

The upstream repo holds only the GameMaker project, and GameMaker's HTML5 export needs a signed-in
GameMaker account (an anonymous IDE builds macOS but refuses HTML5 with "Unable to obtain permission to
execute"). CI has no account, so the export is built locally and committed, unmodified, in
`vendor/blarglike/` (`BUILD.md` there has the exact command). To rebuild it:

1. Install GameMaker (`brew install --cask gamemaker`, in a real terminal: the installer asks for sudo),
   sign in once, and let it install the HTML5 module (select HTML5 as the target once in the IDE).
2. Fetch the project at the pinned commit:
   `curl -fsSL https://codeload.github.com/alexandersshen/blarglike/tar.gz/b78b60dc40de0ba83fe1071e5d9873f2de9a1b05 | tar -xz`
3. Build with Igor, GameMaker's command-line builder (the HTML5 command is `zip`, not `PackageZip`):

       R=/Users/Shared/GameMakerStudio2/Cache/runtimes/runtime-2024.14.4.268
       "$R/bin/igor/osx/arm64/Igor" -j=8 --project=Blarglike.yyp \
         --user="$HOME/Library/Application Support/GameMakerStudio2/<user>_<id>" \
         --runtimePath="$R" --runtime=VM --cache=cache --temp=temp \
         --of=out/index.html --tf=blarglike.zip -- HTML5 zip

4. Unzip `blarglike.zip` into `site/vendor/blarglike/`, keeping `LICENSE` and `BUILD.md`.

The project was saved with GameMaker 2024.4; the committed export was built with IDE 2024.14.4.222 and
runtime 2024.14.4.268.

## How these differ from the competition's games

Found by diffing the dataset copies against upstream:

- **Asteroid Capitalist**: game code (`index.html`, `app.js`, `vendors.js`) identical to release 1.1; the
  dataset only drops unused images (spare ship colours, meteors, explosions, UI digits).
- **Cavebots**: the same game. `index.html` and `wasm_exec.js` are identical, and the dataset's `main.wasm`
  records the same commit (`vcs.revision=15fb598…`), Go version, build flags and dependency versions as
  this site's rebuild. The two files differ only in the build ID, the 128 bytes of git build info the
  dataset's copy embeds (`vcs.time`, `vcs.modified=true`, …), and, as a result, 13,912 addresses that are
  all shifted by exactly +128; the compiled code and embedded assets are otherwise byte-identical.
- **Off Line**: the one game the competition changed meaningfully, all in `script.js`: the squares come from
  a seeded generator reset every attempt (upstream: `Math.random`), so the course is the same each time;
  a collected blue square stays hidden until it falls off the bottom; Space starts through the normal
  reset; and the start-screen label says "Arrow Keys" (upstream says "WASD", though it only ever read the
  arrow keys).
- **Blarglike**: the dataset ships a compiled GameMaker export and upstream ships source, so they can't be
  diffed directly. The upstream build seeds its dungeon from the date ("Daily Run").

The scored evaluation adds further game fixes and fixed engine seeds on top of the dataset copies (dataset
README), so there are three versions of each game: upstream (this site), the dataset, and the evaluation's.
