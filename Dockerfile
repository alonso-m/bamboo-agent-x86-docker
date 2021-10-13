FROM adoptopenjdk:16-jdk-hotspot-focal
LABEL maintainer="Atlassian Bamboo Team" \
      description="Official Bamboo Agent Docker Image"

ENV BAMBOO_USER=bamboo
ENV BAMBOO_GROUP=bamboo

ENV BAMBOO_USER_HOME=/home/${BAMBOO_USER}
ENV BAMBOO_AGENT_HOME=${BAMBOO_USER_HOME}/bamboo-agent-home

ENV INIT_BAMBOO_CAPABILITIES=${BAMBOO_USER_HOME}/init-bamboo-capabilities.properties
ENV BAMBOO_CAPABILITIES=${BAMBOO_AGENT_HOME}/bin/bamboo-capabilities.properties

RUN set -x && \
     addgroup ${BAMBOO_GROUP} && \
     adduser ${BAMBOO_USER} --home ${BAMBOO_USER_HOME} --ingroup ${BAMBOO_GROUP} --disabled-password

RUN set -x && \
     apt-get clean && \
     apt-get update && \
     apt-get install -y --no-install-recommends \
     curl \
     git \
     maven \
     jq \
     tini \
     && \
# create symlink for java home backward compatibility
     mkdir -m 755 -p /usr/lib/jvm && \
     ln -s "${JAVA_HOME}" /usr/lib/jvm/java-8-openjdk-amd64 && \
     rm -rf /var/lib/apt/lists/*

RUN apt-get update -y && \
    apt-get upgrade -y && \     
  	apt-get install apt-transport-https ca-certificates gnupg-agent software-properties-common lsb-release ssh -y

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
RUN apt-get install docker-ce-cli -y

WORKDIR ${BAMBOO_USER_HOME}
USER ${BAMBOO_USER}

ARG BAMBOO_VERSION=7.2.4
ARG DOWNLOAD_URL=https://packages.atlassian.com/maven-closedsource-local/com/atlassian/bamboo/atlassian-bamboo-agent-installer/${BAMBOO_VERSION}/atlassian-bamboo-agent-installer-${BAMBOO_VERSION}.jar
ENV AGENT_JAR=${BAMBOO_USER_HOME}/atlassian-bamboo-agent-installer.jar

RUN set -x && \
     curl -L --silent --output ${AGENT_JAR} ${DOWNLOAD_URL} && \
     mkdir -p ${BAMBOO_USER_HOME}/bamboo-agent-home/bin

COPY --chown=bamboo:bamboo bamboo-update-capability.sh bamboo-update-capability.sh
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.jdk.JDK 1.8" ${JAVA_HOME}/bin/java

COPY --chown=bamboo:bamboo runAgent.sh runAgent.sh
ENTRYPOINT ["./runAgent.sh"]
