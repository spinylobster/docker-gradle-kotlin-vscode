FROM zenika/kotlin:1.3-jdk12

WORKDIR /root

RUN yum -y update && yum clean all && yum -y install \
	wget \
	unzip

# Gradle install
# refer: https://github.com/keeganwitt/docker-gradle/blob/1718fa65873e24d1e003dcd3828755e9fd39fa9d/jdk11-slim/Dockerfile

ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 5.3.1

ARG GRADLE_DOWNLOAD_SHA256=1c59a17a054e9c82f0dd881871c9646e943ec4c71dd52ebc6137d17f82337436
RUN set -o errexit -o nounset \
	&& echo "Downloading Gradle" \
	&& wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
	\
	&& echo "Checking download hash" \
	&& echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
	\
	&& echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
	&& ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
	\
	&& echo "Adding gradle user and group" \
	&& groupadd --system --gid 1000 gradle \
	&& useradd --system --gid gradle --uid 1000 --shell /bin/bash --create-home gradle \
	&& mkdir /home/gradle/.gradle \
	&& chown --recursive gradle:gradle /home/gradle \
	\
	&& echo "Symlinking root Gradle cache to gradle Gradle cache" \
	&& ln -s /home/gradle/.gradle /root/.gradle

# VSCode install and setup
# (This needs root. so it has to be put before switching user.)

COPY ./vscode.repo /etc/yum.repos.d/
RUN yum install -y code
RUN yum install -y which
# for VS Live Share
RUN yum install -y libicu gnome-keyring xorg-x11-utils

# Create Gradle volume
USER gradle
VOLUME "/home/gradle/.gradle"
WORKDIR /home/gradle

RUN set -o errexit -o nounset \
	&& echo "Testing Gradle installation" \
	&& gradle --version

# install extensions
RUN code --install-extension MS-vsliveshare.vsliveshare && \
    code --install-extension fwcd.kotlin
VOLUME "/home/gradle/.vscode"

ENTRYPOINT ["bash", "-c", "chown -R gradle:gradle /home/gradle/.gradle/ /home/gradle/.vscode/ /project && su gradle"]
