# Template Dockerfile for Batch Jobs
#
# help: https://github.com/INWTlab/r-docker
#
# Author: Sebastian Warnholz
FROM inwt/r-batch:4.2.1

ADD . .

RUN apt-get update \
    && apt-get install -y pandoc \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/* \
    && installPackage \
    && R -e "install.packages('rmarkdown')"
