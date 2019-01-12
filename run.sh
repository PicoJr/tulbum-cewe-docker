xhost +LOCAL:
docker run -i -t --name tualbum -e DISPLAY=unix$DISPLAY --device /dev/snd --device /dev/dri -v /dev/shm:/dev/shm -v /tmp/.X11-unix:/tmp/.X11-unix --volume /data/Fotos:/data/Fotos:ro --volume /data/tualbum-cewe:/data/tualbum-cewe tualbum 

