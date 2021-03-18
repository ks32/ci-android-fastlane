#
# GitLab CI: Android v0.1
#
# https://hub.docker.com/r/ks32/ci-android-fastlane
# https://github.com/ks32/ci-android-fastlane
# //update

FROM ubuntu:18.04
MAINTAINER Asif Hisam <asif@noemail.com>

ENV VERSION_TOOLS "6200805"

ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update \
 && apt-get install -qqy software-properties-common \
 && apt-add-repository ppa:brightbox/ruby-ng \
 && apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-8-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      ruby-full \
      build-essential \
      locales \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /tools.zip \
 && mkdir -p ${ANDROID_HOME} \
 && unzip /tools.zip -d ${ANDROID_HOME} \
 && rm -v /tools.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
 && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_HOME/licenses/android-sdk-license \
 && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_HOME/licenses/android-sdk-preview-license \
 && yes | ${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses >/dev/null

ADD packages.txt /sdk
RUN mkdir -p /root/.android \
 && touch /root/.android/repositories.cfg \
 && ${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt \
 && ${ANDROID_HOME}/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} ${PACKAGES}

#RUN gem install -n ${ANDROID_HOME}/tools/bin fastlane

#RUN gem install -n ${ANDROID_HOME}/tools/bin fastlane-plugin-increment_version_code

RUN gem install fastlane -NV \
  && gem install fastlane-plugin-increment_version_code \
  && gem update --system "$RUBYGEMS_VERSION"

#ADD id_rsa $HOME/.ssh/id_rsa
#ADD id_rsa.pub $HOME/.ssh/id_rsa.pub
ADD adbkey $HOME/.android/adbkey
ADD adbkey.pub $HOME/.android/adbkey.pub
