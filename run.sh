xhost +LOCAL:
# /dev/snd system sound, see https://github.com/jlesage/docker-firefox#sound-support
# /dev/dri system gpu interface
# /dev/shm system shared memory, see https://github.com/jlesage/docker-firefox#increasing-shared-memory-size
# /tmp/.X11-unix:/tmp/.X11-unix X11 forwarding
docker run -i -t --rm --name tualbum -e DISPLAY=unix$DISPLAY \
    --device /dev/snd \
    --device /dev/dri \
    -v /dev/shm:/dev/shm \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --volume /mnt/Fotos:/data/Fotos:ro \
    --volume /mnt/tualbum-cewe:/data/tualbum-cewe \
    --entrypoint="/home/tualbum/CEWE Photoworld" tualbum

