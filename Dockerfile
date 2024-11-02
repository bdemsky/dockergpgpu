FROM ubuntu:20.04

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update
RUN apt-get dist-upgrade -y

RUN apt-get -y install build-essential xutils-dev bison zlib1g-dev flex libglu1-mesa-dev wget

RUN apt-get -y install doxygen graphviz

# RUN apt-get -y install python-pmw python-ply python-numpy libpng12-dev python-matplotlib

RUN apt-get -y install python-pmw python-ply python-numpy libpng-dev python3-matplotlib

# RUN apt-get -y install libxi-dev libxmu-dev libglut3-dev
RUN apt-get -y install libxi-dev libxmu-dev freeglut3-dev


# RUN wget https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/cuda_9.1.85_387.26_linux -P /tmp

RUN wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run -P /tmp

RUN sh /tmp/cuda_11.8.0_520.61.05_linux.run --silent --toolkit --toolkitpath=/usr/local/cuda
# ENV CUDA_INSTALL_PATH=/usr/local/cuda
RUN echo "export CUDA_INSTALL_PATH=/usr/local/cuda" >> ~/.bashrc
RUN echo "export PATH=/usr/local/cuda/bin:$PATH" >> ~/.bashrc


RUN apt-get -y install openssh-server

# Setup SSH

RUN mkdir /root/.ssh
RUN echo 'root:helix' | chpasswd
COPY start.sh /start.sh
RUN chmod +x /start.sh
COPY id_rsa* /root/.ssh/
COPY known_hosts /root/.ssh/
# Copy over build scripts

# Finish setup of ssh
EXPOSE 22
ENV TINI_VERSION v0.19.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN mkdir /var/run/sshd
RUN chown root:root /var/run/sshd
RUN chmod 755 /var/run/sshd

# Copy over build scripts

COPY buildscript /root/buildscript
RUN chmod 755 /root/buildscript

COPY runsim /root/runsim
RUN chmod 755 /root/runsim

COPY vectorAdd.cu /root/vectorAdd.cu

RUN apt-get -y install git emacs


ENTRYPOINT ["/tini", "-g", "--"]
CMD /start.sh