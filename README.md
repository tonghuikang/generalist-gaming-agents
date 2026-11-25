# generalist-gaming-agents
The four public sample games of Kaggle's
[Generalist Gaming Agent](https://www.kaggle.com/competitions/generalist-gaming-agent) competition, playable in the
browser and built from their authors' open-source repositories (all MIT), pinned to a commit, with each game's
license served beside it. Nothing here comes from the competition dataset.

- `site/index.html`: all four games on one page; `site/play.html`: one game at a time.
- `site/build.sh`: fetches and builds the games (Cavebots needs Go 1.20.8; CI has it).
- `site/README.md`: how each game is reproduced and how it differs from the competition's copy.
- `.github/workflows/pages.yml`: builds the site and deploys it to GitHub Pages on every push to `master`.

## Serve locally

```sh
site/build.sh _site                      # fetch and build the games into _site/
python3 -m http.server 8000 -d _site     # then open http://localhost:8000/
```

`site/build.sh` needs `curl`, `tar` and `unzip`, and network access to GitHub (it downloads each game at its pinned
commit). Cavebots is compiled only when Go is on `PATH`; use Go 1.20.8 to match the published build (for example
`go install golang.org/dl/go1.20.8@latest && go1.20.8 download`, then put that `go` first on `PATH`). Without Go the
other three games still build and Cavebots is left out. Serve the folder over HTTP as above rather than opening the
files directly, since the pages fetch `games.json` and Cavebots loads WebAssembly.

| Game | Authors | Source |
|---|---|---|
| Asteroid Capitalist | Garlov and Sidaroth | [Sidaroth/Asteroid.Capitalist](https://github.com/Sidaroth/Asteroid.Capitalist) |
| Blarglike | Shenbot Makes (Alexander Shen) | [alexandersshen/blarglike](https://github.com/alexandersshen/blarglike) |
| Cavebots | Iskander (quasilyte) | [quasilyte/cavebots-game](https://github.com/quasilyte/cavebots-game) |
| Off Line | gllms (dolorfox) | [gllms/off-line](https://github.com/gllms/off-line) |
