#https://github.com/sjitech/ndk-workspace/blob/master/Dockerfile
FROM osexp2000/android-gcc-toolchain

RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gcc g++ gcc-multilib g++-multilib ccache
RUN git clone https://github.com/nodejs/node

COPY build-nodejs-for-android ./
RUN sudo chown devuser:devuser build-nodejs-for-android

ENV PATH=$PATH:/home/devuser

RUN ccache -M 50G
ENV USE_CCACHE=1

WORKDIR /home/devuser/node

RUN git checkout v6.5.0
RUN build-nodejs-for-android --arch arm    -o /home/devuser/nodejs-6.5.0-android-arm         --pre-clean --post-clean .
RUN build-nodejs-for-android --arch arm    -o /home/devuser/nodejs-6.5.0-android-arm-full    --pre-clean --post-clean . --full
RUN build-nodejs-for-android --arch arm64  -o /home/devuser/nodejs-6.5.0-android-arm64       --pre-clean --post-clean .
RUN build-nodejs-for-android --arch arm64  -o /home/devuser/nodejs-6.5.0-android-arm64-full  --pre-clean --post-clean . --full
RUN build-nodejs-for-android --arch x86    -o /home/devuser/nodejs-6.5.0-android-x86         --pre-clean --post-clean .
RUN build-nodejs-for-android --arch x86    -o /home/devuser/nodejs-6.5.0-android-x86-full    --pre-clean --post-clean . --full
RUN build-nodejs-for-android --arch x64    -o /home/devuser/nodejs-6.5.0-android-x64         --pre-clean --post-clean .
RUN build-nodejs-for-android --arch x64    -o /home/devuser/nodejs-6.5.0-android-x64-full    --pre-clean --post-clean . --full
RUN build-nodejs-for-android --arch mipsel -o /home/devuser/nodejs-6.5.0-android-mipsel      --pre-clean --post-clean .
RUN build-nodejs-for-android --arch mipsel -o /home/devuser/nodejs-6.5.0-android-mipsel-full --pre-clean --post-clean . --full
