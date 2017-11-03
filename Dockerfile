FROM debian:jessie
MAINTAINER gsefanof@gmail.com

ENV JDK_URL http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.tar.gz
ENV JDK_HOME /usr/java/jdk
ENV JAVA_HOME /usr/java/jre
ENV WEBSWING_VERSION webswing-2.4
ENV WEBSWING_HOME /opt/${WEBSWING_VERSION}
ENV WEBSWING_URL https://bitbucket.org/meszarv/webswing/downloads/${WEBSWING_VERSION}-distribution.zip

ENV WEBSWING_DATA "/webswing"

ENV PATH $PATH:$JAVA_HOME/bin
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -qy --no-install-recommends \
		unzip \
    curl \
    ca-certificates ca-certificates-java \
    xvfb xauth libxi6 libxtst6 libxrender1 libxslt1.1 \
    libxext6 libglib2.0-0 libgtk2.0-bin libxi6 gtk2-engines-murrine \
    libcanberra-gtk-module libdconf1 libswt-gtk-3-java libgtk-3-0 \
    xserver-xorg-core \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${JDK_HOME} && ln -fs ${JDK_HOME}/jre $JAVA_HOME && \
        curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.pem \
  	  --header "Cookie: oraclelicense=accept-securebackup-cookie;" "$JDK_URL" \
	  | tar -xz --strip-components=1 -C ${JDK_HOME} 

RUN update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 1 && \
	update-alternatives --install "/usr/bin/javaws" "javaws" "${JAVA_HOME}/bin/javaws" 1 && \
	update-alternatives --set java "${JAVA_HOME}/bin/java" && \
	update-alternatives --set javaws "${JAVA_HOME}/bin/javaws" && \
  rm -f "${JAVA_HOME}/lib/security/cacerts" && \
  ln -fs /etc/ssl/certs/java/cacerts "${JAVA_HOME}/lib/security/cacerts"


RUN curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.pem \
   ${WEBSWING_URL} -o webswing.zip && \
   unzip -u webswing.zip -d /opt && rm -f webswing.zip

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8080 8443
VOLUME [ "${WEBSWING_DATA}" ]
WORKDIR "${WEBSWING_DATA}"
ENTRYPOINT /docker-entrypoint.sh

