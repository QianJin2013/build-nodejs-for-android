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
RUN mkdir ../logs
RUN build-nodejs-for-android . --arch arm    -o ../nodejs-6.5.0-android-arm         --pre-clean --post-clean         2>&1 | tee ../logs/nodejs-6.5.0-android-arm
RUN build-nodejs-for-android . --arch arm    -o ../nodejs-6.5.0-android-arm-full    --pre-clean --post-clean --full  2>&1 | tee ../logs/nodejs-6.5.0-android-arm-full
RUN build-nodejs-for-android . --arch arm64  -o ../nodejs-6.5.0-android-arm64       --pre-clean --post-clean         2>&1 | tee ../logs/nodejs-6.5.0-android-arm64
RUN build-nodejs-for-android . --arch arm64  -o ../nodejs-6.5.0-android-arm64-full  --pre-clean --post-clean --full  2>&1 | tee ../logs/nodejs-6.5.0-android-arm64-full
RUN build-nodejs-for-android . --arch x86    -o ../nodejs-6.5.0-android-x86         --pre-clean --post-clean         2>&1 | tee ../logs/nodejs-6.5.0-android-x86
RUN build-nodejs-for-android . --arch x86    -o ../nodejs-6.5.0-android-x86-full    --pre-clean --post-clean --full  2>&1 | tee ../logs/nodejs-6.5.0-android-x86-full
RUN build-nodejs-for-android . --arch x64    -o ../nodejs-6.5.0-android-x64         --pre-clean --post-clean         2>&1 | tee ../logs/nodejs-6.5.0-android-x64
RUN build-nodejs-for-android . --arch x64    -o ../nodejs-6.5.0-android-x64-full    --pre-clean --post-clean --full  2>&1 | tee ../logs/nodejs-6.5.0-android-x64-full
RUN build-nodejs-for-android . --arch mipsel -o ../nodejs-6.5.0-android-mipsel      --pre-clean --post-clean         2>&1 | tee ../logs/nodejs-6.5.0-android-mipsel
RUN build-nodejs-for-android . --arch mipsel -o ../nodejs-6.5.0-android-mipsel-full --pre-clean --post-clean --full  2>&1 | tee ../logs/nodejs-6.5.0-android-mipsel-full
