FROM stackbrew/ubuntu:14.04
MAINTAINER Jeff Morgan "jam1401@gmail.com"

RUN apt-get update && apt-get clean
RUN apt-get install -q -y openjdk-7-jdk wget unzip lib32stdc++6 lib32z1 && apt-get clean

ADD http://mirrors.jenkins-ci.org/war/1.576/jenkins.war /opt/jenkins.war
RUN chmod 644 /opt/jenkins.war
ENV JENKINS_HOME /jenkins
ENV WGET wget --no-check-certificate -q
VOLUME /jenkins/jobs

# Install Android SDK
RUN mkdir /usr/local/android
ADD http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz /usr/local/android/android-sdk_r23.0.2-linux.tgz
WORKDIR /usr/local/android
RUN tar -xzvf android-sdk_r23.0.2-linux.tgz
RUN echo "y" | ./android-sdk-linux/tools/android update sdk --no-ui --all --filter platform-tools,build-tools-20.0.0,build-tools-19.1.0,android-19,android-20,extra-android-support,extra-google-google_play_services
ENV ANDROID_HOME /usr/local/android/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Install rbenv for rails builds
RUN apt-get install -y --force-yes ant git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties
RUN apt-get clean

# Install rbenv and ruby-build
WORKDIR /root
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

# Install multiple versions of ruby
ENV CONFIGURE_OPTS --disable-install-doc
ADD ./versions.txt /root/versions.txt
RUN xargs -L 1 rbenv install < /root/versions.txt

# Install Bundler for each version of ruby
RUN echo 'gem: --no-rdoc --no-ri' >> /root/.gemrc
RUN bash -l -c 'for v in $(cat /root/versions.txt); do rbenv global $v; gem install bundler; done'
RUN ln -s /root/.rbenv /.rbenv

# Install various plugins
ADD ./plugins.txt /root/plugins.txt
RUN mkdir -p /jenkins/plugins
RUN bash -l -c 'for v in $(cat /root/plugins.txt); do cd $JENKINS_HOME/plugins;curl -O http://ftp-chi.osuosl.org/pub/jenkins/plugins/$v/latest/$v.hpi; done'

# Add ssh
RUN mkdir /root/.ssh
ADD ./keys/id_rsa /root/.ssh/id_rsa
ADD ./keys/id_rsa.pub /root/.ssh/id_rsa.pub

ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]
EXPOSE 8080

CMD [""]
