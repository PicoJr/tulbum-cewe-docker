# tualbum-cewe-docker

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

```
# /mnt/Fotos : folder for photos (read only)
# /data/Fotos : where photos are located within docker container (when running the application)
# /mnt/tualbum-cewe : folder for retrieving albums
# /data/tualbum-cewe : where albums should be saved within docker container (when running the application)
--volume /mnt/Fotos:/data/Fotos:ro \
--volume /mnt/tualbum-cewe:/data/tualbum-cewe \
```

You may need to edit the `entrypoint` to match the program name depending on the locale:

```
# for english
--entrypoint="/home/tualbum/CEWE Photoworld"
# for French
--entrypoint="/home/tualbum/Atelier Photo Fnac"
```

Start tualbum cewe docker container:

```
./run.bash
```
