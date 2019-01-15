# Data Carpentry Genomics Dockerfile
#
# Based on Ubuntu
FROM ubuntu:bionic-20181112
#
# Maintained by
MAINTAINER Jason Williams "williams@cshl.edu"
#
# Un-minimize the image to get back Ubuntu
# goodies for teaching Linux/bash (e.g. man files, etc)
# this makes the container big
RUN apt-get update && apt-get upgrade -y && \
 (echo y | DEBIAN_FRONTEND=noninteractive sh -x /usr/local/sbin/unminimize)
#
#
# Install additional linux basics/common dependancies
RUN apt update -y && apt upgrade -y && apt-get install -y --fix-missing\
 software-properties-common\
 build-essential gcc\
 build-essential\
 dialog\
 libssl1.0-dev\
 zip\
 unzip\
 git\
 tmux\
 libedit2\
 lsb-release\
 psmisc\
 sudo\
 openssh-server\
 apparmor-profiles\
 libxml2-dev\
 pkg-config\
 libxt-dev\
 libfreetype6-dev\
 libzmq3-dev\
 htop\
 libhdf5-dev\
 libglib2.0-0\
 libxext6\
 libsm6\
 libxrender1\
 openssl\
 npm nodejs\
 nodejs
#
#
# Install Conda
RUN wget --quiet\
 https://repo.anaconda.com/archive/Anaconda3-5.3.1-Linux-x86_64.sh\
  -O Anaconda3-5.3.1-Linux-x86_64.sh &&\
  /bin/bash Anaconda3-5.3.1-Linux-x86_64.sh -b -p /opt/conda &&\
  rm Anaconda3-5.3.1-Linux-x86_64.sh &&\
  ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh &&\
  echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc
#
#
# Configure conda
RUN /opt/conda/bin/conda config --add channels defaults
RUN /opt/conda/bin/conda config --add channels bioconda
RUN /opt/conda/bin/conda config --add channels conda-forge
#
#
# Install bioconda packages
RUN /opt/conda/bin/conda install -y -q fastqc=0.11.7=5
RUN /opt/conda/bin/conda install -y -q trimmomatic=0.38=0
RUN /opt/conda/bin/conda install -y -q bwa=0.7.17=ha92aebf_3
RUN /opt/conda/bin/conda install -y -q samtools=1.9=h8ee4bcc_1
RUN /opt/conda/bin/conda install -y -q bcftools=1.8=h4da6232_3
#
#
# Link conda executables to /bin and /usr/lib
RUN ln -s /opt/conda/pkgs/*/bin/* /bin; exit 0
RUN ln -s /opt/conda/pkgs/*/lib/* /usr/lib; exit 0
#
#
# Install R and packages
RUN  apt-key adv --keyserver keyserver.ubuntu.com\
 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9\
 && sh -c 'echo\
  "deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/"\
   >> /etc/apt/sources.list'
RUN apt-get update\
 && apt-get upgrade -y -q\
 && apt-get install -y --no-install-recommends\
 r-recommended\
 r-base\
 r-base-dev
#
#
# Install R packages
RUN R -e "install.packages('devtools')"
RUN R -e "install.packages('BiocManager')"
RUN R -e "install.packages('XML')"
RUN R -e "install.packages('tidyverse')"
RUN R -e "install.packages('ggplot2')"
RUN R -e "install.packages('knitr')"
RUN R -e "install.packages('rmarkdown')"
RUN R -e "install.packages('packrat')"
#
#
# Install RStudio Server
ADD https://s3.amazonaws.com/rstudio-server/current.ver /tmp/ver
ENV CRAN_URL https://cloud.r-project.org/
RUN apt-get update\
 && apt-get upgrade -y -q\
 && apt-get install -y --no-install-recommends\
 gdebi\
 curl
RUN set -e\
 && ln -s /dev/stdout /var/log/syslog\
 && curl -S -o /tmp/rstudio.deb http://download2.rstudio.org/rstudio-server-$(cat /tmp/ver)-amd64.deb\
 && gdebi -n /tmp/rstudio.deb\
 && rm -rf /tmp/rstudio.deb /tmp/ver
#
#
# Set the locale and environment variables
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen &&\
 locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
#
#
# Configure environment
ENV DEBIAN_FRONTEND=noninteractive \
 LANG=en_US.UTF-8 \
 LANGUAGE=en_US.UTF-8 \
 LC_ALL=en_US.UTF-8 \
 LC_COLLATE=en_US.UTF-8 \
 LC_CTYPE=en_US.UTF-8 \
 LC_MESSAGES=en_US.UTF-8 \
 LC_MONETARY=en_US.UTF-8 \
 LC_NUMERIC=en_US.UTF-8 \
 LC_TIME=en_US.UTF-8

# Expose port for RStudio Server 8787 and SSH port
EXPOSE 8787
EXPOSE 22
#
# Start the container - will create users in username.txt if they do
# not already exist and start the hub.
ENTRYPOINT ["/docker-persistant/initiate.sh"]
