FROM adoptopenjdk:8-jdk-hotspot-focal
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
     apt-get update && \
     apt-get install -y --no-install-recommends \
          curl \
          tini \
     && \
# create symlink for java home backward compatibility
     mkdir -m 755 -p /usr/lib/jvm && \
     ln -s "${JAVA_HOME}" /usr/lib/jvm/java-8-openjdk-amd64 && \
     rm -rf /var/lib/apt/lists/*

WORKDIR ${BAMBOO_USER_HOME}
USER ${BAMBOO_USER}

ARG BAMBOO_VERSION
ARG DOWNLOAD_URL=https://packages.atlassian.com/maven-closedsource-local/com/atlassian/bamboo/atlassian-bamboo-agent-installer/${BAMBOO_VERSION}/atlassian-bamboo-agent-installer-${BAMBOO_VERSION}.jar
ENV AGENT_JAR=${BAMBOO_USER_HOME}/atlassian-bamboo-agent-installer.jar

RUN set -x && \
     curl -L --silent --output ${AGENT_JAR} ${DOWNLOAD_URL} && \
     mkdir -p ${BAMBOO_USER_HOME}/bamboo-agent-home/bin

COPY --chown=bamboo:bamboo bamboo-update-capability.sh bamboo-update-capability.sh
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.jdk.JDK 1.8" ${JAVA_HOME}/bin/java

COPY --chown=bamboo:bamboo runAgent.sh runAgent.sh
ENTRYPOINT ["./runAgent.sh"]
