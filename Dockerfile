FROM ubuntu:14.04
MAINTAINER kr3ssh@gmail.com

ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv C3173AA6 \
 && echo 'deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main' >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y \
    ca-certificates nginx nginx-extras nodejs \
    locales pkg-config g++ cmake \
    ruby2.2 ruby2.2-dev make \
    libssl-dev libpq-dev libyaml-dev libicu-dev \
    git curl wget libxml2-dev libxslt1-dev libffi-dev \
    libyaml-0-2 libpq5 libicu52 \
    libreadline6-dev zlib1g zlib1g-dev \
    file imagemagick python-pygments \
 && gem install --no-document bundler

RUN locale-gen en_US.UTF-8 \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8

# Stop nginx server
RUN /etc/init.d/nginx stop

ADD conf/nginx/default /etc/nginx/sites-enabled/default
ADD entrypoint.sh run.sh /

RUN chmod +x /*.sh
RUN mkdir /data /var/log/zumhotface

ENV RAILS_ENV production

RUN git clone https://github.com/digitalhelpersleague/zumhotface.git /opt/zumhotface
WORKDIR /opt/zumhotface

COPY conf/app/Procfile conf/app/.env /opt/zumhotface/

RUN bundle install --deployment --without development test && \
  ZHF_SECRET_KEY=hello \
  bundle exec rake assets:precompile

# Purge build dependencies
RUN apt-get purge -y --auto-remove gcc g++ make patch pkg-config cmake \
  libc6-dev libpq-dev zlib1g-dev libyaml-dev libssl-dev \
  libreadline6-dev libxml2-dev libxslt-dev libffi-dev \
  ruby2.2-dev manpages-dev libgmp-dev \
  && apt-get clean

VOLUME /data
VOLUME /opt/zumhotface
VOLUME /var/log/zumhotface

EXPOSE 8080
#EXPOSE 8443

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/run.sh"]
