# reference: https://hub.docker.com/_/ubuntu/
FROM python:3.8-slim

# meta data for container labeling
LABEL maintainer="Ken Trinh <ktrinh.particle@gmail.com>"

# env language -> standardized to utf8
# fix encoding issues
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update --fix-missing                                                            \
    && apt-get install -y git                                                               \
    && export DEBIAN_FRONTEND=noninteractive                                                \
    && apt-get update -y                                                                    \
    && apt-get -y install tmux                                                              \
    && apt-get install software-properties-common -y                                        \
############
            build-essential python-dev python3-dev curl wget                                \
            libssl-dev                                                                      \
            libffi-dev                                                                      \
            libkrb5-dev                                                                     \
            liblzma-dev                                                                     \
            unixodbc-dev                                                                    \
            unixodbc                                                                        \
            libpq-dev                                                                       \
            jq                                                                              \
            vim
############

#install python 3 in the image
RUN apt-get -y install python3-pip
RUN pip3 install --upgrade pip

# install python specific packages
COPY requirements.txt .
RUN pip3 install --user -r requirements.txt
RUN pip3 install jupyter 

# making stdout unbuffered (any non empty string works)
ENV PYTHONUNBUFFERED="jsspdockerexp"


# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

# COPY src src

# command that start up jupyer notebook when docker run is call
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
