FROM alpine:latest
MAINTAINER Matt Bentley <mbentley@mbentley.net>

# install ca-certificates, ffmpeg, and java7
RUN (apk --no-cache add ca-certificates ffmpeg openjdk7-jre-base)

# Install the official subsonic 5.3 standalone package and add subsonic.war from https://github.com/EugeneKay/subsonic
RUN (apk --no-cache add wget &&\
  wget "http://sourceforge.net/projects/subsonic/files/subsonic/5.3/subsonic-5.3-standalone.tar.gz/download" -O /tmp/subsonic.tar.gz &&\
  mkdir /var/subsonic &&\
  tar zxf /tmp/subsonic.tar.gz -C /var/subsonic &&\
  rm /tmp/subsonic.tar.gz &&\
  wget "https://github.com/EugeneKay/subsonic/releases/download/v5.3-kang/subsonic-v5.3-kang.war" -O /var/subsonic/subsonic.war &&\
  apk del wget &&\
  adduser -h /var/subsonic -D subsonic &&\
  chown -R subsonic:subsonic /var/subsonic)

# create transcode folder and add ffmpeg
RUN (mkdir /var/subsonic/transcode &&\
  ln -s /usr/bin/ffmpeg /var/subsonic/transcode/ffmpeg &&\
  chown -R subsonic:subsonic /var/subsonic/transcode)

# create data directories and symlinks to make it easier to use a volume
RUN (mkdir /data &&\
  cd /data &&\
  mkdir db jetty lucene2 lastfmcache thumbs music Podcast playlists &&\
  touch subsonic.properties subsonic.log &&\
  cd /var/subsonic &&\
  ln -s /data/db &&\
  ln -s /data/jetty &&\
  ln -s /data/lucene2 &&\
  ln -s /data/lastfmcache &&\
  ln -s /data/thumbs &&\
  ln -s /data/music &&\
  ln -s /data/Podcast &&\
  ln -s /data/playlists &&\
  ln -s /data/subsonic.properties &&\
  ln -s /data/subsonic.log &&\
  chown -R subsonic:subsonic /data)

USER subsonic
WORKDIR /var/subsonic
EXPOSE 4040
VOLUME ["/data"]

CMD ["java","-Xmx1024m","-Dsubsonic.home=/var/subsonic","-Dsubsonic.host=0.0.0.0","-Dsubsonic.port=4040","-Dsubsonic.contextPath=/","-Dsubsonic.defaultMusicFolder=/data/music","-Dsubsonic.defaultPodcastFolder=/data/Podcast","-Dsubsonic.defaultPlaylistFolder=/data/playlists","-Djava.awt.headless=true","-jar","subsonic-booter-jar-with-dependencies.jar"]
