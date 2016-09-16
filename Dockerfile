#https://github.com/sjitech/ndk-workspace/blob/master/Dockerfile
FROM osexp2000/android-gcc-toolchain

CMD ["/bin/bash", "-l"]

RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gcc g++ gcc-multilib g++-multilib ccache
RUN git clone https://github.com/nodejs/node

RUN git clone https://github.com/sjitech/build-nodejs-for-android -b master --single-branch
ENV PATH=$PATH:/home/devuser/build-nodejs-for-android

RUN build-nodejs-for-android-v 6.6.0
