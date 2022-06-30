FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENVPNAS_VERSION
#ARG 2.11.0
LABEL build_version="${VERSION} Build-date:- ${BUILD_DATE}"


# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install dependencies ****" && \
 apt-get update && \
 apt-get install -y \
	bridge-utils dmidecode iptables iproute2 libc6  libffi7  libgcc-s1 liblz4-1  liblzo2-2 libmariadb3 libpcap0.8 libssl3   libstdc++6 libsasl2-2 libsqlite3-0 net-tools python3-pkg-resources python3-migrate python3-sqlalchemy python3-mysqldb python3-ldap3 sqlite3 zlib1g  python3-netaddr python3-arrow python3-lxml \
	libxmlsec1 libxmlsec1-openssl python3-attr python3-automat python3-bcrypt python3-cffi-backend python3-click python3-colorama python3-constantly python3-cryptography python3-hamcrest python3-hyperlink python3-idna python3-incremental python3-openssl python3-pyasn1-modules python3-service-identity python3-twisted python3-zope.interface

RUN \
 echo "**** install additional dependencies ****" && \
 apt-get update && \
 apt-get install -y \
 bzip2 file libgdbm-compat4 libgdbm6 libiptc0 libmagic-mgc libmagic1 libperl5.34 mailcap mime-support perl perl-modules-5.34 xz-utils

RUN \
 echo "**** add openvpn-as repo ****" && \
 # TODO: save gpg key in new format. (apt deprecation warning)
 curl -s https://as-repository.openvpn.net/as-repo-public.gpg | apt-key add - && \
 echo "deb http://as-repository.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as-repo.list && \
 if [ -z ${OPENVPNAS_VERSION+x} ]; then \
	OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/jammy/main/binary-amd64/Packages.gz | gunzip -c \
	|grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}');\
 fi && \
 echo "$OPENVPNAS_VERSION" > /version.txt && \
 echo "**** ensure home folder for abc user set to /config ****" && \
 usermod -d /config abc && \
 echo "**** create admin user and set default password for it ****" && \
 useradd -s /sbin/nologin admin && \
 echo "admin:passwOrd+2" | chpasswd && \
 rm -rf \
	/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 943/tcp 1194/udp 9443/tcp
VOLUME /config
