# Blarglike web build

HTML5 export of [alexandersshen/blarglike](https://github.com/alexandersshen/blarglike) (MIT, see LICENSE)
at commit b78b60dc40de0ba83fe1071e5d9873f2de9a1b05, unmodified. GameMaker's HTML5 export needs a signed-in
GameMaker account, which CI doesn't have, so the export is committed here and site/build.sh copies it.

Built with GameMaker IDE 2024.14.4.222, runtime 2024.14.4.268 (VM):

    Igor -j=8 --project=Blarglike.yyp --user=<GameMaker user dir> --runtimePath=<runtime> --runtime=VM \
      --cache=<dir> --temp=<dir> --of=out/index.html --tf=blarglike.zip -- HTML5 zip
