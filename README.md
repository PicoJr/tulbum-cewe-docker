# tulbum-cewe-docker

Tested with version `6.4.7` YMMV.

## Quick Start

Download installer from official website: <https://cewe-photoworld.com/creator-software/linux-download>.

```
git clone <this-repo>
cd <repo>
```

Copy `install.pl`, `EULA.txt` next to the Dockerfile.

Remove EULA agreement interactive question from script:

```
./remove_eula_from_script.sh
```

Build docker image:

```
docker build . -t tualbum
```

Edit `run.sh` volumes (see `--volumes` options)

Start tulbum cewe docker container:

```
./run.bash
```
