FROM ubuntu:16.04

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install ca-certificates curl wget apt-transport-https lsb-release libgomp1 jq apt-utils
RUN echo "deb https://HorizenOfficial.github.io/repo/ $(lsb_release -cs) main" | tee --append /etc/apt/sources.list.d/zen.list
RUN rm -rf /var/lib/apt/lists/*
RUN gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv 219F55740BBF7A1CE368BA45FB7053CE4991B669
RUN gpg --export 219F55740BBF7A1CE368BA45FB7053CE4991B669 | apt-key add -
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install zen
RUN latestBaseUrl="$(curl -s https://api.github.com/repos/tianon/gosu/releases | grep browser_download_url | head -n 1 | cut -d '"' -f 4 | sed 's:/[^/]*$::')" \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && curl -o /usr/local/bin/gosu -SL "$latestBaseUrl/gosu-$dpkgArch" \
    && curl -o /usr/local/bin/gosu.asc -SL "$latestBaseUrl/gosu-$dpkgArch.asc"
RUN mkdir -p ~/.gnupg
RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
RUN gpg --no-tty --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN gpg --no-tty --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu
RUN rm -rf /usr/local/bin/gosu.asc
RUN chmod +x /usr/local/bin/gosu
RUN gosu nobody true
RUN apt-get clean

# Default p2p communication port, can be changed via $OPTS (e.g. docker run -e OPTS="-port=9876")
# or via a "port=9876" line in zen.conf.
#Defaults are 9033/19033 (Testnet)
EXPOSE 9033
EXPOSE 19033

# Default rpc communication port, can be changed via $OPTS (e.g. docker run -e OPTS="-rpcport=8765")
# or via a "rpcport=8765" line in zen.conf. This port should never be mapped to the outside world
# via the "docker run -p/-P" command.
#Defaults are 8231/18231 (Testnet)
EXPOSE 8231
EXPOSE 18231

# Data volumes, if you prefer mounting a host directory use "-v /path:/mnt/zen" command line
# option (folder ownership will be changed to the same UID/GID as provided by the docker run command)
VOLUME ["/mnt/zen"]

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["zend"]
