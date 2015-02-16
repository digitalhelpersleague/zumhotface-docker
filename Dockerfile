FROM debian:jessie
MAINTAINER kr3ssh@gmail.com

ENV DEBIAN_FRONTEND noninteractive

# Setup build dependencies
RUN apt-get update \
  && apt-get install -y nginx nginx-extras nodejs \
    locales pkg-config \
    cmake autoconf bison libreadline6-dev zlib1g zlib1g-dev \
    build-essential libssl-dev libpq-dev libyaml-dev libicu-dev \
    git curl wget libxml2-dev libxslt1-dev libffi-dev \
    libyaml-0-2 libpq5 file imagemagick

RUN locale-gen en_US.UTF-8 \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8

# Stop nginx server
RUN /etc/init.d/nginx stop

COPY conf/nginx/zumhotface.conf /etc/nginx/sites-enabled/default
COPY entrypoint.sh run.sh /

RUN chmod +x /*.sh
RUN mkdir /data /var/log/zumhotface

RUN git clone https://github.com/sstephenson/rbenv.git /opt/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /opt/rbenv/plugins/ruby-build
RUN /opt/rbenv/plugins/ruby-build/install.sh
ENV PATH /opt/rbenv/bin:/opt/rbenv/shims:$PATH

RUN eval "$(rbenv init -)"
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile
# TODO: maybe its better to update /etc/profile

ENV RUBY_CONFIGURE_OPTS --enable-shared
ENV RAILS_ENV production

RUN rbenv install 2.2.0 && \
  rbenv global 2.2.0 && \
  rbenv exec gem install --no-document bundler && \
  rbenv rehash

RUN git clone https://github.com/digitalhelpersleague/zumhotface.git /opt/zumhotface
WORKDIR /opt/zumhotface

COPY conf/app/Procfile conf/app/.env /opt/zumhotface/

RUN rbenv exec bundle install --deployment --without development test && \
  ZHF_SECRET_KEY=hello \
  rbenv exec bundle exec rake assets:precompile

# Purge build dependencies
RUN apt-get purge -y --auto-remove gcc g++ make patch pkg-config cmake \
  libc6-dev libpq-dev zlib1g-dev libyaml-dev libssl-dev \
  libreadline6-dev libxml2-dev libxslt-dev libffi-dev \
  && apt-get clean

VOLUME /data
VOLUME /opt/zumhotface
VOLUME /var/log/zumhotface

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/run.sh"]
