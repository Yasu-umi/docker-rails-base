FROM dockerfile/ubuntu

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --force-yes \
      build-essential \
      bison \
      libreadline6-dev \
      curl \
      git-core \
      zlib1g-dev \
      libssl-dev \
      libxml2 \
      libyaml-dev \
      libxml2-dev \
      libxslt1-dev \
      libmysqld-dev \
      autoconf \
      libncurses5-dev

RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

RUN ./.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

ENV CONFIGURE_OPTS --disable-install-doc
ADD ./ruby-versions.txt /root/ruby-versions.txt
RUN xargs -L 1 rbenv install < /root/ruby-versions.txt && \
    xargs -L 1 rbenv rehash
RUN echo 'gem: --no-document' > /usr/local/etc/gemrc

# Install Bundler for each version of ruby
RUN bash -l -c 'for v in $(cat /root/ruby-versions.txt); do rbenv global $v; gem install bundler; done'

# install sqlite3
RUN apt-get install -y sqlite3 libsqlite3-dev

# Install Node.js and npm
RUN \
  apt-get install -y software-properties-common && \
  apt-get update && \
  add-apt-repository -y ppa:chris-lea/node.js && \
  echo "deb http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y nodejs

# Define default command.
CMD ["bash"]
