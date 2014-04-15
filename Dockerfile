# Select ubuntu as the base image
FROM ubuntu

VOLUME ["~/.ssh"]

# Install nginx, nodejs and curl
RUN apt-get update -q
RUN apt-get install -qy nginx
RUN apt-get install -qy curl
RUN apt-get install -qy nodejs
RUN apt-get install -qy git
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Install rvm, ruby, bundler
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.1.0"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# Let's hack around setting up ssh key to clone a private github repo.
RUN mkdir -p /root/.ssh
ADD ~/.ssh/id_rsa /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

# Clone maudit repo
RUN git clone git@github.com:mdsol/maudit.git

ADD ./maudit /maudit
WORKDIR /maudit
RUN /bin/bash -l -c "bundle install"
EXPOSE 3009

ENTRYPOINT "foreman start"
