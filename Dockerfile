FROM ubuntu:trusty

MAINTAINER Jason Chaffee <jasonchaffee@gmail.com>

RUN apt-get update -y \
    && apt-get install -y software-properties-common python-software-properties \
    && add-apt-repository ppa:openjdk-r/ppa \
    && apt-get update -y \
    && apt-get clean all \
    && apt-get install -y git git-svn subversion \
    && apt-get install -y colordiff postfix \
    && apt-get install -y gzip tar unzip \
    && apt-get install -y vim tmux xterm lynx curl wget \
    && apt-get install -y tightvncserver #xfce4 xfce4-goodies

ENV DOCKER_VERSION 1.6.0
ENV DOCKER_COMPOSE_VERSION 1.2.0
ENV DOCKER_MACHINE_VERSION v0.2.0

ENV JAVA_7 1.7.0
ENV JAVA_8 1.8.0
ENV JAVA_HOME_VERSION ${JAVA_7}

ENV SCALA_VERSION 2.11.6
ENV TYPESAFE_ACTIVATOR_VERSION 1.3.2

ENV GIT_USER_NAME John Doe
ENV GIT_USER_EMAIL john.doe@mycompany.com

ENV JAVA_HOME /usr/lib/jvm//usr/lib/jvm/java-${JAVA_HOME_VERSION}-openjdk-amd64

ENV MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=512m -XX:+CMSClassUnloadingEnabled"
ENV SBT_OPTS="-Xmx512m -XX:+CMSClassUnloadingEnabled -Dsbt.override.build.repos=false -Dsbt.jse.engineType=Node"

RUN wget -qO- https://get.docker.com/ | sh

RUN curl -SL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && curl -SL https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

RUN curl -SL https://github.com/docker/machine/releases/download/${DOCKER_MACHINE_VERSION}/docker-machine_linux-amd64 -o /usr/local/bin/docker-machine \
    && chmod +x /usr/local/bin/docker-machine

RUN apt-get install -y openjdk-7-jdk \
    && apt-get install -y openjdk-8-jdk \
	&& apt-get install -y maven

RUN echo "deb http://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list \
    && apt-get update -y \
    && apt-get install -y --force-yes sbt \
    && curl -SL http://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.deb -o scala-${SCALA_VERSION}.deb \
    && dpkg -i scala-${SCALA_VERSION}.deb \
    && apt-get install -f \
	&& curl -SL http://downloads.typesafe.com/typesafe-activator/${TYPESAFE_ACTIVATOR_VERSION}/typesafe-activator-${TYPESAFE_ACTIVATOR_VERSION}-minimal.zip -o typesafe-activator-${TYPESAFE_ACTIVATOR_VERSION}-minimal.zip \
	&& unzip typesafe-activator-${TYPESAFE_ACTIVATOR_VERSION}-minimal.zip -d /usr/local/ \
	&& ln -s /usr/local/activator-${TYPESAFE_ACTIVATOR_VERSION}-minimal /usr/local/typesafe-activator \
	&& ln -s /usr/local/typesafe-activator/activator /usr/local/bin/activator

COPY bashrc .bashrc
RUN mv .bashrc ~/.bashrc

COPY gitignore .gitignore
RUN mv .gitignore ~/.gitignore

COPY setup.sh setup.sh
RUN chmod +x setup.sh

RUN mkdir -p ~/.vnc \
    && echo password | vncpasswd -f > ~/.vnc/passwd \
    && chmod 600 ~/.vnc/passwd

EXPOSE 5901

CMD /setup.sh && vncserver :1 -name vnc -geometry 800x640 && tail -f ~/.vnc/*:1.log
