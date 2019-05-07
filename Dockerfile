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
 nodejs\
 libncurses5-dev\
 libncursesw5-dev\
 ncurses-term
#
#
# Instal latex
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -q && apt-get install -qy \
    texlive-full \
    python-pygments gnuplot \
    make git \
&& rm -rf /var/lib/apt/lists/*
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
 r-recommended=3.5.2-1bionic\
 r-base=3.5.2-1bionic\
 r-base-dev=3.5.2-1bionic\
 curl\
 libgit2-dev
#
#
# Install R packages
RUN R -e "install.packages('devtools')"
RUN R -e "devtools::install_version('BiocManager', version='1.30.4', repos='http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('XML', version='3.98-1.16', repos='http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('tidyverse', version='1.2.1', repos='http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('ggplot2', version='3.1.0', repos='http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('knitr', version='1.21', repos='http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('rmarkdown', version='1.11', repos='http://cran.us.r-project.org')"
RUN R -e "devtools::install_version('packrat', version='0.5.0', repos='http://cran.us.r-project.org')"
#
#
# Install RStudio Server
ENV CRAN_URL https://cloud.r-project.org/
RUN apt-get update\
 && apt-get upgrade -y -q\
 && apt-get install -y --no-install-recommends\
 gdebi
RUN set -e\
 && ln -s /dev/stdout /var/log/syslog\
 && curl -S -o /tmp/rstudio.deb https://download2.rstudio.org/server/trusty/amd64/rstudio-server-1.2.1335-amd64.deb\
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
# Expose port for RStudio Server 8787 and SSH port
EXPOSE 8787
EXPOSE 22
#
#
# Start the container - will create users in username.txt if they do
# not already exist and start services.
CMD ["/docker-persistant/initiate.sh"]
