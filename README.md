# build-nodejs-for-android-perfectly
Build nodejs for android(arm,arm64,x86,x64,mipsel) perfectly and provide prebuilt binaries via docker images.

- `Perfectly` means do not add any `--without-...` option, nor modifying any source(include build settings) as possible.
    Accomplished by tool [android-gcc-toolchain](https://github.com/sjitech/android-gcc-toolchain).
    See [Full Build](#full-build). This tool
    > Enable you to use NDK's standalone toolchain easily, quickly and **magically** for cross-compile.

- Prebuilt nodejs-android-{arm,arm64,x86,x64,mipsel} are available from [Docker Images](#docker-images). 

## Development Environment

**Source of [NodeJS](https://github.com/nodejs/node): 6.3.1-6.5.0**

OS:
- **Mac**: OS X 10.11.5/10.11.6 EI Capitan (64bit)
- **Linux**: Ubuntu 16.04 (64bit)
- **Windows**: Windows Pro 7.
 
    Use [Docker Images](#docker-images) via [Docker-Toolbox](https://www.docker.com/products/docker-toolbox).

NDK: 
 - [NDK 12.1.29 For Mac 64bit](https://dl.google.com/android/repository/android-ndk-r12b-darwin-x86_64.zip)
 - [NDK 12.1.29 For Linux 64bit](https://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip)

Auxiliary tool:
- [android-gcc-toolchain](https://github.com/sjitech/android-gcc-toolchain)

(Optional) CCACHE:
- **To speed up repeating compilation, you'd better add `--ccache` option for `android-gcc-toolchain`**

    First you need install `ccache` by `brew install ccache` on Mac or `sudo apt-get install ccache` on Linux. then:
    
    ```
    export USE_CCACHE=1             #you'd better put this line to your ~/.bash_profile etc.
    export CCACHE_DIR=~/ccache      #you'd better put this line to your ~/.bash_profile etc.
    ccache -M 50G                   #set cache size once is ok
    ```
    
(Optional) `build-nodejs-for-android`: (provided by this project)
- This further simplified build. e.g. The following commands do all limited and full build for nodejs 6.5.0, output to specified dirs.

    ```
    cd node && git checkout v6.5.0
    build-nodejs-for-android --arch arm    -o ../nodejs-6.5.0-android-arm         --pre-clean --post-clean .
    build-nodejs-for-android --arch arm    -o ../nodejs-6.5.0-android-arm-full    --pre-clean --post-clean . --full
    build-nodejs-for-android --arch arm64  -o ../nodejs-6.5.0-android-arm64       --pre-clean --post-clean .
    build-nodejs-for-android --arch arm64  -o ../nodejs-6.5.0-android-arm64-full  --pre-clean --post-clean . --full
    build-nodejs-for-android --arch x86    -o ../nodejs-6.5.0-android-x86         --pre-clean --post-clean .
    build-nodejs-for-android --arch x86    -o ../nodejs-6.5.0-android-x86-full    --pre-clean --post-clean . --full
    build-nodejs-for-android --arch x64    -o ../nodejs-6.5.0-android-x64         --pre-clean --post-clean .
    build-nodejs-for-android --arch x64    -o ../nodejs-6.5.0-android-x64-full    --pre-clean --post-clean . --full
    build-nodejs-for-android --arch mipsel -o ../nodejs-6.5.0-android-mipsel      --pre-clean --post-clean .
    build-nodejs-for-android --arch mipsel -o ../nodejs-6.5.0-android-mipsel-full --pre-clean --post-clean . --full
    ```

## Limited build

- Drop some features by `--without-snapshot` `--without-inspector` `--without-intl` then build on Mac/Linux.

```
android-gcc-toolchain arm    <<< "./configure --dest-cpu=arm    --dest-os=android --without-snapshot --without-inspector --without-intl && make"
android-gcc-toolchain arm64  <<< "./configure --dest-cpu=arm64  --dest-os=android --without-snapshot --without-inspector --without-intl && make"
android-gcc-toolchain x86    <<< "./configure --dest-cpu=x86    --dest-os=android --without-snapshot --without-inspector --without-intl && make"
android-gcc-toolchain x64    <<< "./configure --dest-cpu=x64    --dest-os=android --without-snapshot --without-inspector --without-intl --openssl-no-asm && make"
android-gcc-toolchain mipsel <<< "./configure --dest-cpu=mipsel --dest-os=android --without-snapshot --without-inspector --without-intl && make"
```
    
For x64: `--openssl-no-asm` needed due to openssl not ready for android-x64.

## Full build

Using `android-gcc-toolchain --hack ... -C`, you can build nodejs **with all features** easily.

see [About hack mode](https://github.com/sjitech/android-gcc-toolchain#user-content-about-hack-mode), 
it's not terrible as sound, it just supersede compiler commands in $PATH and add/remove some option.

### Full build on Mac

```
android-gcc-toolchain arm    --hack ar-dual-os,gcc-no-lrt,gcc-m32 -C <<< "./configure --dest-cpu=arm    --dest-os=android && make"
android-gcc-toolchain arm64  --hack ar-dual-os,gcc-no-lrt         -C <<< "./configure --dest-cpu=arm64  --dest-os=android && make"
android-gcc-toolchain x86    --hack ar-dual-os,gcc-no-lrt,gcc-m32 -C <<< "./configure --dest-cpu=x86    --dest-os=android && make"
android-gcc-toolchain x64    --hack ar-dual-os,gcc-no-lrt         -C <<< "sed -i.bak 's/cross_compiling = target_arch != host_arch/cross_compiling = True/' configure && ./configure --dest-cpu=x64 --dest-os=android --openssl-no-asm && make"
android-gcc-toolchain mipsel --hack ar-dual-os,gcc-no-lrt,gcc-m32 -C <<< "./configure --dest-cpu=mipsel --dest-os=android && make"
```
The sed command is to modify a bug of `configure`. 
 
### Full build on Linux
 
```
android-gcc-toolchain arm    --hack gcc-lpthread,gcc-m32 -C <<< "./configure --dest-cpu=arm    --dest-os=android && make"
android-gcc-toolchain arm64  --hack gcc-lpthread         -C <<< "./configure --dest-cpu=arm64  --dest-os=android && make"
android-gcc-toolchain x86    --hack gcc-lpthread,gcc-m32 -C <<< "sed -i.bak 's/cross_compiling = target_arch != host_arch/cross_compiling = True/' configure && ./configure --dest-cpu=x86 --dest-os=android && make"
android-gcc-toolchain x64    --hack gcc-lpthread         -C <<< "sed -i.bak 's/cross_compiling = target_arch != host_arch/cross_compiling = True/' configure && ./configure --dest-cpu=x64 --dest-os=android --openssl-no-asm && make"
android-gcc-toolchain mipsel --hack gcc-lpthread,gcc-m32 -C <<< "./configure --dest-cpu=mipsel --dest-os=android && make"
```

For x86:You must install 32bit lib by `sudo apt-get install -y g++-multilib gcc-multilib`,otherwise complained about sys/cdefs.h etc. not found.

### Full build on Windows
 
Use following docker images.

----

## Docker images

- [osexp2000/build-nodejs-android-arm-full](https://github.com/sjitech/build-nodejs-android-arm-full)
- [osexp2000/build-nodejs-android-arm-limited](https://github.com/sjitech/build-nodejs-android-arm-limited)
- [osexp2000/build-nodejs-android-arm64-full](https://github.com/sjitech/build-nodejs-android-arm64-full)
- [osexp2000/build-nodejs-android-arm64-limited](https://github.com/sjitech/build-nodejs-android-arm64-limited)
- [osexp2000/build-nodejs-android-mipsel-full](https://github.com/sjitech/build-nodejs-android-mipsel-full)
- [osexp2000/build-nodejs-android-mipsel-limited](https://github.com/sjitech/build-nodejs-android-mipsel-limited)
- [osexp2000/build-nodejs-android-x64-full](https://github.com/sjitech/build-nodejs-android-x64-full)
- [osexp2000/build-nodejs-android-x64-limited](https://github.com/sjitech/build-nodejs-android-x64-limited)
- [osexp2000/build-nodejs-android-x86-full](https://github.com/sjitech/build-nodejs-android-x86-full)
- [osexp2000/build-nodejs-android-x86-limited](https://github.com/sjitech/build-nodejs-android-x86-limited)

**I am prepare a single docker image with all output of all arch of v6.5.0**

Notes:
- Name conventions: `-full` means full version(no `--without-...`), while `-limited` means --without-snapshot --without-inspector --without-intl.
- To enter the container, run `docker run` command e.g. `docker run -it osexp2000/android-arm-full`
- Build already done. The output are mainly stored at `~/usr/local/bin`(node) and `~/out`(cctest, openssl-cli...).
- Built on latest source of nodejs *at that time*. Run `cd ~/node && git log -1 --oneline` to check source version.
- The source of NodeJS is at `~/node`, you can use git there or `~/git-pull.sh`, `~/git-clean.sh`.
- You can run `./build.sh` in the container to build yourself, it is fast for unchanged files because of ccache.
- These docker images share common base image so the download size will be reduced from second image. 
- Quick start of docker:
    - The docker run `-it` means `--interactive --tty`.
    - Use volume mapping `-v HOST_DIR_OR_FILE:CONTAINER_DIR_OR_FILE` to map dir/files to container. 
      Note: **Docker-Toolbox on Windows need host dir or files is under `C:\Users\...`(e.g. C:\Users\q\Downloads),
      and the `HOST_DIR_OR_FILE` must be converted to `/c/Users/...` style.**
    - Use `docker cp` to copy files in/out when forgot to use volume mapping.
    - Do not specify `-t`(`--tty`) if to feed commands to docker via <<<"Here String" or <<EOF Here Document.

----

## Run compiled nodejs-android on android

Successfully tested on real device or emulator 
- nodejs-android-arm-full
- nodejs-android-arm-limited
- nodejs-android-arm64-full
- nodejs-android-arm64-limited. 

Some experiences:

### Install build result into android

```
$ make DESTDIR=/tmp/nodejs install
$ adb push /tmp/nodejs/usr/local/bin/node /data/local/tmp/
$ adb push /tmp/nodejs/usr/local/lib /data/local/tmp/
$ adb shell chmod -R 755 /data/local/tmp/node /data/local/tmp/lib 
```

### Run nodejs

Just run /data/local/tmp/node, be need first set `export NODE_REPL_HISTORY=/data/local/tmp/node_history`,
otherwise `Error: Could not open history file. REPL session history will not be persisted.`.

### Run npm

Use following script as npm, then you can use `npm install`, `-g` also allowed.
```
export HOME=/data/local/tmp
export NODE_REPL_HISTORY=$HOME/node_history
mkdir $HOME/npm-global 2> /dev/null
export NPM_CONFIG_PREFIX=$HOME/npm-global
$HOME/node $HOME/lib/node_modules/npm/bin/npm-cli.js "$@"
```

----

## Miscellaneous

- What on earth is the --without-snapshot?

    It is to not convert js to C/C++ on compile time. Seems no problem if specified.
    If not specified, it will try to make a tool `mksnapshot` then run this tool to convert js to `snapshot.cc`
    which in turn get compiled by android-side compiler. The snapshot seems used for quick js context creation. 

- What on earth is the --without-intl?

    It is to not provide `Intl` feature, a global class named `Intl`. 
    Note: **The `Intl` is not necessary!**
    Do not be confused about description “Flags that lets you enable i18n features in Node.js”,
    it does not mean you can not use non-english chars。
    
    The `Intl` feature is rarely used, it is an option definition by ECMAScript-402,
    a locale management in js, e.g. sort, date format....
    
    Without `Intl`, nodejs works fine with multi-byte chars via UTF8. Anyway, to convert across CodePage,
    you still need iconv-lite etc.
    
    NodeJS use [icu](http://site.icu-project.org/) project to implement `Intl` feature 
    while `icu` often cause problem in cross-compile because it need build host-side exe such as genccode,icupkg 
    then run them to generate temp C source.
    
    The icu project looks ugly, see [Home page](http://site.icu-project.org/),
     [DEMO](http://demo.icu-project.org/icu-bin/collation.html),
     [Unicode Browser](http://demo.icu-project.org/icu-bin/ubrowse),
        
----

# NodeJS for Android完美编译大全

完美地编译了NodeJS for android-{arm,arm64,x86,x64,mipsel},并且通过Docker提供预编译版,也可以作为持续编译环境。

- 完美, 意思是不去掉任何功能(不加`--without-...`选项),尽量不修改任何源码(包括编译设定文件)。
  借助工具[android-gcc-toolchain](https://github.com/sjitech/android-gcc-toolchain)
  实现了这个目标。见[Full Build](#full-build))。这个工具
     
    >让人快捷地使用NDK的独立toolchain做交叉编译,并且有些奇妙的功能。
    
- 预编译好的Docker Images在[这里](#docker-images)

## 由头

交叉编译,是个不大不小的土活儿,很无聊,很干扰正题。

一开始我也没想要搞什么完美编译,我只是因为对[NDK有怨念](http://my.oschina.net/osexp2003/blog/465134),
所以做了个辅助工具[android-gcc-toolchain](https://github.com/sjitech/android-gcc-toolchain) ([这里有简单介绍](http://my.oschina.net/osexp2003/blog/731238)),
以便顺利地做交叉编译。于是一般的交叉编译过程变轻松了之后,就凸显出NodeJS的编译错误了。

编译NodeJS for Android,目前都是去掉某些功能,或者修改源码里的编译设定,才能编译成功,例如:

- --without-snapshot  (\*1)(\*2)
- --openssl-no-asm    (\*1)
- --without-intl      (\*2)
- --without-inspector (\*2)

(\*1):NodeJS源码里的[android-configure](https://github.com/nodejs/node/blob/master/android-configure)
里用了这个。(\*2):这个选项常常被用到。

例如在Mac上编译NodeJS for android-arm64,不去掉任何功能,不修改任何源码(包括编译设定文件),这样的完美编译方法,居然没找到(arm的也是)!

**复杂之处**是因为要生成的东西不仅有node,还有cctest, openssl-cli,似乎是测试工程用的,
而且,**还有用Host(编译工作机器例如Mac/Linux)编译器生成一些Host上运行的临时的执行文件(mksnapshot,icupkg,genccode,genrb,iculslocs)。**
编译设定环节层次太多(gyp,autoconf,CMake,...),不容易完全掌控。
    
就算把gyp所需要的环境变量`CC_target`...,`GYP_DEFINES="host_os=<mac|linux>"`
以及通用的`CXX_host`,`CXX_FLAGS`等设好并添加一些选项也依然会有某些工程不遵循设定。

我发现最终阻拦完美编译的有几个问题,大部分是host这边编译时出的问题。

- **ar**: 静态库生成器ar误用(用Mac的ar命令处理Android的lib),导致连接错误。
- **-lrt**: 试图连接linux特有的librt但实际Mac没有,导致连接错误。
- **-m32**: 有的编译成32bit,有的是64bit,导致连接出错。
- **-lpthread**: 忘了加必要的-l某lib的连接选项了,例如-lpthread,导致连接时报莫名其妙的"DSO missing from command line"错误。

都是源码里的错误造成的(就是编译设定文件有错误,但是不太好找,每次都要伺候这些很烦)。

碰巧都想出了通用的方法,虽然方法有点黑,但是管用,可以完美编译了,于是记录下来。

## 开发环境

源码:
- [NodeJS](https://github.com/nodejs/node): v6.3.1-6.5.0

编译工作机器:
- Mac OS X EI Capitan (10.11.5或10.11.6) (64bit) ([NDK 12.1.29](https://dl.google.com/android/repository/android-ndk-r12b-darwin-x86_64.zip))
- Linux Ubuntu 16.04 (64bit) ([NDK 12.1.29](https://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip))
- Windows: Pro 7 + 用[Docker-Toolbox](https://www.docker.com/products/docker-toolbox)。
    工具`android-gcc-toolchain`是不支持Windows的,所以得在Docker的Linux容器里运行。

NDK: 
 - [NDK 12.1.29 For Mac 64bit](https://dl.google.com/android/repository/android-ndk-r12b-darwin-x86_64.zip)
 - [NDK 12.1.29 For Linux 64bit](https://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip)

辅助工具 tool:
- [android-gcc-toolchain](https://github.com/sjitech/android-gcc-toolchain),下载一下就好了。

(可选) CCACHE
- **为了快速地重复编译,建议给`android-gcc-toolchain`加上`--ccache`选项**,这个会把通过`ccache`的wrapper来调用原来的gcc等命令。

    先安装ccache:`brew install ccache` on Mac or `sudo apt-get install ccache` on Linux。然后:
    
    ```
    export USE_CCACHE=1             #you'd better put this line to your ~/.bash_profile etc.
    export CCACHE_DIR=~/ccache      #you'd better put this line to your ~/.bash_profile etc.
    ccache -M 50G                   #set cache size once is ok
    ```

(可选) 辅助工具 `build-nodejs-for-android`: (就在这个project里)
- 更加简化编译命令. 例如，如下这些命令囊括了接下来所有的命令内容，产生6.5.0的限制版和完全版，放到指定的目录里。

    ```
    cd node && git checkout v6.5.0
    build-nodejs-for-android --arch arm    -o ../nodejs-6.5.0-android-arm         --pre-clean --post-clean .
    build-nodejs-for-android --arch arm    -o ../nodejs-6.5.0-android-arm-full    --pre-clean --post-clean . --full
    build-nodejs-for-android --arch arm64  -o ../nodejs-6.5.0-android-arm64       --pre-clean --post-clean .
    build-nodejs-for-android --arch arm64  -o ../nodejs-6.5.0-android-arm64-full  --pre-clean --post-clean . --full
    build-nodejs-for-android --arch x86    -o ../nodejs-6.5.0-android-x86         --pre-clean --post-clean .
    build-nodejs-for-android --arch x86    -o ../nodejs-6.5.0-android-x86-full    --pre-clean --post-clean . --full
    build-nodejs-for-android --arch x64    -o ../nodejs-6.5.0-android-x64         --pre-clean --post-clean .
    build-nodejs-for-android --arch x64    -o ../nodejs-6.5.0-android-x64-full    --pre-clean --post-clean . --full
    build-nodejs-for-android --arch mipsel -o ../nodejs-6.5.0-android-mipsel      --pre-clean --post-clean .
    build-nodejs-for-android --arch mipsel -o ../nodejs-6.5.0-android-mipsel-full --pre-clean --post-clean . --full
    ```

## Limited Build

去掉NodeJS的一些功能(指定--without-snapshot --without-inspector --without-intl)就可以在Mac/Linux上编译。

```
android-gcc-toolchain arm    <<< "./configure --dest-cpu=arm    --dest-os=android --without-snapshot --without-inspector --without-intl && make"
android-gcc-toolchain arm64  <<< "./configure --dest-cpu=arm64  --dest-os=android --without-snapshot --without-inspector --without-intl && make"
android-gcc-toolchain x86    <<< "./configure --dest-cpu=x86    --dest-os=android --without-snapshot --without-inspector --without-intl && make"
android-gcc-toolchain x64    <<< "./configure --dest-cpu=x64    --dest-os=android --without-snapshot --without-inspector --without-intl --openssl-no-asm && make"
android-gcc-toolchain mipsel <<< "./configure --dest-cpu=mipsel --dest-os=android --without-snapshot --without-inspector --without-intl && make"
```
    
对于x64: 需要加上`--openssl-no-asm`,因为openssl的配置里都没有支持android-x64.

## Full Build

用`android-gcc-toolchain --hack ... -C`可以编译nodejs,包含**所有机能**.

参看[About hack mode](https://github.com/sjitech/android-gcc-toolchain#user-content-about-hack-mode), 
不是想象的那么可怕,只不过是在$PATH里超越本机编译器命令然后加减一点选项罢了。

### Full Build on Mac

```
android-gcc-toolchain arm    --hack ar-dual-os,gcc-no-lrt,gcc-m32 -C <<< "./configure --dest-cpu=arm    --dest-os=android && make"
android-gcc-toolchain arm64  --hack ar-dual-os,gcc-no-lrt         -C <<< "./configure --dest-cpu=arm64  --dest-os=android && make"
android-gcc-toolchain x86    --hack ar-dual-os,gcc-no-lrt,gcc-m32 -C <<< "./configure --dest-cpu=x86    --dest-os=android && make"
android-gcc-toolchain x64    --hack ar-dual-os,gcc-no-lrt         -C <<< "sed -i.bak 's/cross_compiling = target_arch != host_arch/cross_compiling = True/' configure && ./configure --dest-cpu=x64 --dest-os=android --openssl-no-asm && make"
android-gcc-toolchain mipsel --hack ar-dual-os,gcc-no-lrt,gcc-m32 -C <<< "./configure --dest-cpu=mipsel --dest-os=android && make"
```

sed命令是修改源码里configure脚本里的错误.
    
### Full Build on Linux

```
android-gcc-toolchain arm    --hack gcc-lpthread,gcc-m32 -C <<< "./configure --dest-cpu=arm    --dest-os=android && make"
android-gcc-toolchain arm64  --hack gcc-lpthread         -C <<< "./configure --dest-cpu=arm64  --dest-os=android && make"
android-gcc-toolchain x86    --hack gcc-lpthread,gcc-m32 -C <<< "sed -i.bak 's/cross_compiling = target_arch != host_arch/cross_compiling = True/' configure && ./configure --dest-cpu=x86 --dest-os=android && make"
android-gcc-toolchain x64    --hack gcc-lpthread         -C <<< "sed -i.bak 's/cross_compiling = target_arch != host_arch/cross_compiling = True/' configure && ./configure --dest-cpu=x64 --dest-os=android --openssl-no-asm && make"
android-gcc-toolchain mipsel --hack gcc-lpthread,gcc-m32 -C <<< "./configure --dest-cpu=mipsel --dest-os=android && make"
```

对于x86:必须先安装一些32bit的lib:`sudo apt-get install -y g++-multilib gcc-multilib`,否则它报错说sys/cdefs.h找不到。

### Full build on Windows
 
运行如下的docker images.

----

## Docker images

- [osexp2000/build-nodejs-android-arm-full](https://github.com/sjitech/build-nodejs-android-arm-full)
- [osexp2000/build-nodejs-android-arm-limited](https://github.com/sjitech/build-nodejs-android-arm-limited)
- [osexp2000/build-nodejs-android-arm64-full](https://github.com/sjitech/build-nodejs-android-arm64-full)
- [osexp2000/build-nodejs-android-arm64-limited](https://github.com/sjitech/build-nodejs-android-arm64-limited)
- [osexp2000/build-nodejs-android-mipsel-full](https://github.com/sjitech/build-nodejs-android-mipsel-full)
- [osexp2000/build-nodejs-android-mipsel-limited](https://github.com/sjitech/build-nodejs-android-mipsel-limited)
- [osexp2000/build-nodejs-android-x64-full](https://github.com/sjitech/build-nodejs-android-x64-full)
- [osexp2000/build-nodejs-android-x64-limited](https://github.com/sjitech/build-nodejs-android-x64-limited)
- [osexp2000/build-nodejs-android-x86-full](https://github.com/sjitech/build-nodejs-android-x86-full)
- [osexp2000/build-nodejs-android-x86-limited](https://github.com/sjitech/build-nodejs-android-x86-limited)

**正在做成一个单一的Docker imag，囊括6.5.0的所有构架的编译结果**

Notes:
- 名称规范: `-full`表示完全版(没有使用`--without...`),而`-limited`表示--without-snapshot --without-inspector --without-intl.
- 进入这个linux容器的话,执行`docker run`命令就行了。例如`docker run -it osexp2000/android-arm-full`
- 可以在容器里运行`./build.sh`来自己编译, 未改变的源码由于被ccache了所以速度很快。
- 编译已经完成了。生成物主要在`~/usr/local/bin`(node)和`~/out`(cctest, openssl-cli...).
- 使用了当时看来最新的NoeJS源码. 查看版本可以用命令`cd ~/node && git log -1 --oneline`。
- NodeJS源码`~/node`是可以用git管理的,也可以用`~/git-pull.sh`, `~/git-clean.sh`.
- 这些image共享一些基本的image,所以下载数据量会从第二个开始减少。 
- Docker快速入门:
    - 这个docker run里的`-it`表示 `--interactive --tty`.
    - 可以使用卷映射`-v HOST_DIR_OR_FILE:CONTAINER_DIR_OR_FILE`来把本机的目录或者文件映射到容器里。 
      注意: **Docker-Toolbox on Windows要求:host(就是PC机)这边的目录或文件必须是为`C:\Users\...`之下(例如C:\Users\q\Downloads),
      并且`HOST_DIR_OR_FILE`必须转换成`/c/Users/...`形式.**
    - 可以用`docker cp`来copy进出容器,这在有时候忘了做卷映射时可以救急.
    - 有种情况不要用`-t`(`--tty`):当要用<<<"Here String"或<<EOF Here Document向容器输入命令时。

----

## 在Android运行编译出来的nodejs-android

在实机和模拟器里测试成功: 
- nodejs-android-arm-full
- nodejs-android-arm-limited
- nodejs-android-arm64-full
- nodejs-android-arm64-limited. 

一些经验:

### 把编译结果安装到Android里

```
make DESTDIR=/tmp/nodejs install
adb push /tmp/nodejs/usr/local/bin/node /data/local/tmp/
adb push /tmp/nodejs/usr/local/lib /data/local/tmp/
adb shell chmod -R 755 /data/local/tmp/node /data/local/tmp/lib 
```

### 运行nodejs

运行/data/local/tmp/node就行了。但是之前得先`export NODE_REPL_HISTORY=/data/local/tmp/node_history`,
不然会得到`Error: Could not open history file. REPL session history will not be persisted.`.

### 运行npm

用这个script代替npm, 然后就可以用`npm install`, `-g`也行.
```
export HOME=/data/local/tmp
export NODE_REPL_HISTORY=$HOME/node_history
mkdir $HOME/npm-global 2> /dev/null
export NPM_CONFIG_PREFIX=$HOME/npm-global
$HOME/node $HOME/lib/node_modules/npm/bin/npm-cli.js "$@"
```

###具体的测试内容

- 多语言支持

    ```
    > Buffer.from('新')
    <Buffer e6 96 b0>
    ```
      
- 网络和DNS

    ```
    > net.connect({host:"nodejs.org", port:443}, () => {console.log("------connected------")})
    ...
    ------connected------
    ```
      
- SSL

    ```
    > https.get('https://encrypted.google.com/', (res) => {res.on('data', (d) => {process.stdout.write(d);});})
    ...
    <!doctype html><html ...>...</html>
    ```

- Debug

    ```
    generic_arm64:/data/local/tmp $ ./node debug a.js
    debug> 
    (To exit, press ^C again or type .exit)
    < Debugger listening on [::]:5858
    connecting to 127.0.0.1:5858 ... ok
    break in a.js:1
    > 1 console.log(0)
      2 console.log(1)
    ...
    ```

- npm

    ```
    generic_arm64:/data/local/tmp $ ./npm install -g http-server
    /data/local/tmp/npm-global/bin/http-server -> /data/local/tmp/npm-global/lib/node_modules/http-server/bin/http-server
    ...    
    ```

----

# 具体经过的备忘录

## 一两年前

NodeJS对Android支持度很弱,想要Android版的,那就得折腾。那时大致有两种方法:

- 各路高中低手都提供了修改源码里编译配置文件的方法。

    现在大都都已经被合并进来了,不提了。

- Android真机debian Kit里编译。

    在一个root过的Android里装上debian Kit后,就可以轻松编译成功。

    ```
    /configure --without-snapshot --without-npm
    export LDFLAGS=-static  #静态连接
    make
    ```

    美中不足的是,生成的NodeJs居然连localhost这样的名字都解析不了,只能直接用IP。
    这种编译方法没使用android的libc,所以水土不服,例如glibc里的getaddrinfo
    会寻找/etc/resolv.conf之类的东西,而Android实际不用那套机制。

## 最近

又想随手搞一个最新的,记得NodeJS有了不少进展的。结果的确有进展,但是依然不简单。

- 官网里的那个[linux-arm执行文件](https://nodejs.org/dist/v4.4.7/node-v4.4.7-linux-armv7l.tar.xz)是怎么回事?

    可惜在Android里用不了。这大都得怪Android搞了一套和linux不一样的linker和.so。

    - loader不一样。执行时爆"No such file or directory"

        ```
        $ readelf --headers ~/Downloads/node-v4.4.7-linux-armv7l/bin/node | grep interpreter
        [Requesting program interpreter: /lib/ld-linux-armhf.so.3]
        ```
        而Android变态不提供这个linux标准loader,而是用`/system/bin/linker`来调执行文件。

        黑实验：强行改掉,结果引起下一个问题。

    - Android里各个.so的名称都和一般的linux的不一样

        ```
        $ readelf -d ~/Downloads/node-v4.4.7-linux-armv7l/bin/node
        ... Shared library: [libdl.so.2] [librt.so.1] [libstdc++.so.6] ...
        ```

        黑实验：强行改掉依赖的*.so名称,结果引起下一个问题。

    - 没有编译成PIE风格(像*.so一样位置无关以便运行位置随机化),所以会被Android 5+拒绝运行

        ```
        $ readelf -d ~/Downloads/node-v4.4.7-linux-armv7l/bin/node | grep Type:
        Type:                              EXEC (Executable file)
        ```

        而PIE风格的执行文件,至少得和.so一样的类型`DYN (Shared object file)`。

        黑实验：那就在4.4上做实验,结果引起下一个问题。

    - 有些api在android里不存在。

        黑实验：无法继续了。更不要提/etc之类的设定文件不存在引起的主机名解析等问题了。

    跑了一会儿题,接着试试源码里提供的`android-configure`编译脚本。

- 在Mac上执行[android-configure](https://github.com/nodejs/node/blob/master/android-configure),make时出错

    ```
    ./android-configure $NDK && make
    ```
    出错信息：
    ```
    sh: /Users/q/Downloads/node/out/Release/icupkg: cannot execute binary file
    ```
    而且,不能编译arm64构架的。
  
    于是试试源码里提供的`configure`编译脚本。

- 在Mac上执行[configure](https://github.com/nodejs/node/blob/master/configure),也在make时出错

    ```
    ./configure --dest-cpu=arm64 --dest-os=android && make
    ```
    出错信息 openssl里"unsupported ARM architecture"：
    ```
     cc .../obj.target/...openssl...
    ../deps/openssl/openssl/crypto/arm_arch.h:46:6: error: "unsupported ARM architecture"
    ```
    obj.target目录放得都是为android生成的东西,obj.host里的都是为了当前机器生成的东西。

    而这个光秃秃的cc命令就是指host(我的机器)的cc。
    显然这是用错了cc,得告诉他用android的cc。这个看来不能怪NodeJS。
    
    那就照惯例定义一下`$CC`什么的,部分参照`android-configure`,生成单独的toolchain也是必须的,假设生成到/tmp/tc下。
    ```
    $ $NDK/build/tools/make_standalone_toolchain.py --arch arm64 --install-dir /tmp/tc --force
    $ export CC=/tmp/tc/bin/aarch64-linux-android-gcc
    $ export CXX=/tmp/tc/bin/aarch64-linux-android-g++
    $ export AR=/tmp/tc/bin/aarch64-linux-android-ar
    $ export LINK=/tmp/tc/bin/aarch64-linux-android-g++
    $ ./configure --dest-cpu=arm64 --dest-os=android && make
    ```
    果然那一步通过了,cc变成了制定的android gcc了。
    ```
    /tmp/tc/bin/aarch64-linux-android-gcc .../obj.target/...openssl...
    ```
    但是接着出别的错。
    
## 折腾之路

那就在Mac上继续一个个看看怎么回事,为什么编译一个东西还要人费神呢?

- gyp交叉编译系统更需要`$CC_target`...而不是`$CC`...

    新的错误和android-configure的那个一样:
    ```
    sh: /Users/q/Downloads/node_tmp/out/Release/icupkg: cannot execute binary file
    ```
    看来NodeJS用到icu这个东西,他要生成一个我本机用的执行文件,情况复杂了啊。
    
    不但要生成Android的,还要本机用的一些关联的东西,这就是混合模式了。

    似乎`android-configure`加了个`--openssl-no-asm`选项的原因就是为了避免这个错误。
    
    在往一点看,icupkg是由这个命令生成的:
    ```
    /tmp/tc/bin/aarch64-linux-android-g++ ... -o ...icupkg .../obj.host/...icu...
    ```
    这是发神经了吗? 拿android-g++编译obj.host的东西,可icupkg是要在host(也就是我的PC)上执行的啊,
    为什么用android-g++编译呢。
    
    发现在决定host-side的编译器时,用的逻辑在[make.py](https://github.com/nodejs/node/blob/master/tools/gyp/pylib/gyp/generator/make.py#L2068):
    ```
    GetEnvironFallback(('CXX_host', 'CXX'), 'g++')
    ```
    - 优先用$CXX_host
    - 要么就用$CXX
    - 要么就用$PATH里的g++
    
    看来原来设定的`$CXX`得换成`$CXX_target`之类的,于是重新开个bash:
    ```
    $ export CC_target=/tmp/tc/bin/aarch64-linux-android-gcc
    $ export CXX_target=/tmp/tc/bin/aarch64-linux-android-g++
    $ export AR_target=/tmp/tc/bin/aarch64-linux-android-ar
    $ export LINK_target=/tmp/tc/bin/aarch64-linux-android-g++
    $ ./configure --dest-cpu=arm64 --dest-os=android && make
    ```
    果然,本地编译的都通过了,包括刚才的icu模块。
    
- V8(Chromium JavaScript)工程里的host_os设定错误
    
    新的错误是试图编译一个linux特有的文件:
    ```
    g++ ... -c -o .../obj.host/... ...platform-linux.cc
    .../v8/src/base/platform/platform-linux.cc:53:10: fatal error: 'sys/prctl.h' file not found
    ```
    显然这是在编译本地产品时误包括了linux的源码。
    
    查到platform-linux.cc是在[deps/v8/tools/gyp/v8.gyp#L1769](https://github.com/nodejs/node/blob/master/deps/v8/tools/gyp/v8.gyp#L1769)
    里被选定为本地编译对象的。
    ```
    'conditions': [
      ['host_os=="mac"', {
        'target_conditions': [
          ['_toolset=="host"', {
            'sources': [
              '../../src/base/platform/platform-macos.cc'
            ]
          }, {
            'sources': [
              '../../src/base/platform/platform-linux.cc'
            ]
          }],
        ],
      }, {
        'sources': [
          '../../src/base/platform/platform-linux.cc'
        ]
      }],
    ],
    ```
    
    看起来逻辑正确啊,host_os是mac就platform-macos.cc否则就platform-linux.cc。
    强行把上述.cc改成_xxxx1.cc,_xxxx2.cc,_xxxx3.cc后,重新执行configure,就会发现_xxxx3
    出现在一个./out/deps/v8/tools/gyp/v8_libbase.host.mk里。
    
    试着把host_os=="mac"换成host=="android"反倒好了。
    
    确定是host_os搞错了,在看这东西是谁设定的:
    [deps/v8/build/toolchain.gypi#L88](https://github.com/nodejs/node/blob/master/deps/v8/build/toolchain.gypi#L88)
    ```
    'host_os%': '<(OS)',
    ```
    上下看看就会明白`OS`就是target OS,就是android了。这个`host_os`在这个文件其他地方都没有被用到。
    
    而另一个它的使用者[deps/v8/build/standalone.gypi#L264](https://github.com/nodejs/node/blob/master/deps/v8/build/standalone.gypi#L264)
    ```
    'host_os%': "<!(uname -s | sed -e 's/Linux/linux/;s/Darwin/mac/')",
    ```
    正确的检测了host_os,结果是"mac". 用这句话替换掉`'host_os%': '<(OS)'`,那么就OK了。
    
    但是,这个修改影响较大(例如Windows没有uname命令,还得换成一段python才行),搞不好就是这么设计的,让使用者在外层设定。
    反正一时半会儿考虑不全不好提交修改。
    
    于是一查怎么把host_os变量从./configure那层传递给gyp,发现又转到了android-configure里:
    ```
    GYP_DEFINES+=" host_os=linux OS=android"
    export GYP_DEFINES
    ./configure ...
    ```
    不过显然,作者当时用的是linux主机做这事儿的,我得设成mac。于是:
    
    ```
    $ export GYP_DEFINES=host_os=mac
    $ export CC_target=/tmp/tc/bin/aarch64-linux-android-gcc
    $ export CXX_target=/tmp/tc/bin/aarch64-linux-android-g++
    $ export AR_target=/tmp/tc/bin/aarch64-linux-android-ar
    $ export LINK_target=/tmp/tc/bin/aarch64-linux-android-g++
    $ ./configure --dest-cpu=arm64 --dest-os=android && make
    ```

- 试图连接linux特有的librt(经-lrt选项)

    新的错误是创建本地产品时的linker错误
    ```
    g++ ... -o ...mksnapshot .../obj.host/... -dl -lrt
    ld: library not found for -lrt
    ```
    这是试图在host上寻找librt,但是如果手动执行不包括-lrt的命令,就会成功。
    
    这个错误同样是在[deps/v8/tools/gyp/v8.gyp#L1769](https://github.com/nodejs/node/blob/master/deps/v8/tools/gyp/v8.gyp#L1763)
    里,作者肯定是在Linux主机上工作所以不出问题。
    ```
    'libraries': [
        '-ldl',
        '-lrt'
    ]
    ```

    这个v8.gyp以后肯定是要改的,但是先想了个黑办法对付过去。
    那就是把libdl复制成librt,把路径包含在LIBRARY_PATH里,让ld能够找到。
    ```
    $ find -L /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs -type f -name 'libdl.*'
    /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/usr/lib/libdl.tbd
    $ cp /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/usr/lib/libdl.tbd \
      /tmp/tc/librt.tbd
    $ export LIBRARY_PATH=/tmp/tc:$LIBRARY_PATH
    ```
    OK,这一关通过了。
    
    近一步试探,发现librt.tbd里只要写这么多就行了(包括...三个字符都得原原本本的写进去)。
    ```
    archs:           [ i386, x86_64 ]
    platform:        macosx
    install-name:    /usr/lib/libSystem.B.dylib
    exports:         
      - archs:           [ i386, x86_64 ]
        re-exports:      [  ]
        symbols:         [  ]
    ...
    ```
    2016/09/06:这个方法后来换成了gcc-no-lrt这个hack option,超越系统原有的gcc等命令,把-lrt参数给去掉后在调用原本的gcc等。
    
- 静态库生成器ar误用

    新的问题就是一开始碰到的那一堆符号找不到的linker错误了。例如:
    ```
    .../obj.target/cctest/src/inspector_socket.o: In function `inspector_write(inspector_socket_s*, char const*, unsigned long)':
    inspector_socket.cc:(.text+0x1af4): undefined reference to `uv_buf_init'
    ```
    往上查这些.o的用处时,发现本机的ar命令居然用来生成Android的静态库了!乱套了。
    ```
    rm -f .../obj.target/tools/icu/libicustubdata.a && \
    ar crsT .../obj.target/tools/icu/libicustubdata.a \
            .../obj.target/...一堆.o文件 
    ```
    看来有有些子工程不听话啊,压根不鸟`$AR_target`所指定的ar。
    这查起来就啰嗦了,真不想进那些散发着腐朽味道的工程里。
    在Linux上看不出问题,因为Linux主机上的ar使用的格式和Android上的一样,而Mac上的略有不同。
    从Wiki上看,ar命令内部文件格式从来就没有统一过。
    
    怎么办?似乎就差这一步了。忽然想起一个黑主意:做个wrapper ar代替本机的,里面判断输入的*.o文件格式,
    从而决定调用本机的还是Android的ar。判断就用toolchain里的objdump好了,如果不出错说明是Android的。
    
    ...省略,枯燥无味。都集成到android-gcc-toolchain了。

## 其他

- 到底是啥啊?这个--without-snapshot

    意思是不对js进行预编译。去掉这个功能似乎不是什么大事儿。
    不指定这个选项时,make会先生成一个mksnapshot工具,然后运行这个工具生成snapshot.cc,
    里面包含了所有的js的预编译结果,然后再把这个snapshot.cc编译成android这边的机器码。
    这个snapshot似乎是为了快速创建新的js context,也许Electron,NW.js之类和UI的时候需要用吧。

- 到底是啥啊?这个--without-intl

    意思是不提供`Intl`机能,一个叫做`Intl`的全局class。
    **`Intl`不是必须的！**
    别被介绍里的“Flags that lets you enable i18n features in Node.js”给吓着了,
    搞得好像是没了他就不支持多语言似的了。
    
    `Intl`这个新东西几乎没人用,是什么ECMAScript-402标准里定义的一个可选项,就是做文字列的排序,日期格式等locale那套功能。
    
    没有`Intl`机能的话,一切都转的好好的。UTF8,中文,日语什么的都支持。
    不管怎样,需要转换文字集时还是需要iconv-lite等东西。
    
    NodeJS用icu这个文字集转换库实现了intl功能,但是icu经常在交叉编译是出毛病,因为它要生成一些本地exe,例如genccode,icupkg,
    然后调用genccode根据一个数据文件生成C代。
    
    icu这个东西看起来有种腐朽的味道,看他的网页就知道了(例如[主页](http://site.icu-project.org/),[DEMO](http://demo.icu-project.org/icu-bin/collation.html),[Unicode Browser](http://demo.icu-project.org/icu-bin/ubrowse)),
    那个土啊,别提了,显然没人好好打理。

- V8(Chromium JavaScript)工程里的东西好庞大,而且显得老旧了。很不好参与。

- gyp那套编译工具有成功之处,比Makefile好懂。但居然还是得一个个加源码文件?不能"目录/*.c"外加一些exclude的形式加到sources里吗?

- 在Mac上编译NodeJS for Android-arm时碰到的错误和解决方法

    这次多了一个问题,也是gyp或者别的什么的错误,也是host这边编译问题,而且还是icu那一块的。
    
    反正是有的编译成32bit,有的是64bit。
    不好查找。所以烦了,还是继续原来的野路子吧,把gcc和g++都给替换了,里面强制加上-m32选项。
    
    最终,这一切集成到android-gcc-toolchain里,通过`--hack ar-dual-os,gcc-no-lrt,gcc-m32`选项可以实现。

- 2016/09/02: 在Linux上编译NodeJS for Android-arm64时碰到的错误和解决方法

    这次多了一个问题,又是host这边编译问题,是最终连接生成mksnapshot时除奇怪的错:
    ```
    /usr/bin/ld: .../obj.host/.../v8/.../platform/condition-variable.o: undefined reference to symbol 'pthread_condattr_setclock@@GLIBC_2.3.3'
    //lib/x86_64-linux-gnu/libpthread.so.0: error adding symbols: DSO missing from command line
    ```
    说符号找不到还有DSO什么莫名其妙的东西,我用nm查了发现符号就在libpthread里,所以加个-lpthread让他连接libpthread就行了。
    
    当然,到底在那个配置文件里加这个选项,有得头痛的层层追寻配置,不想干了。还不如黑路子快,
    最终,把这一切集成到android-gcc-toolchain里,通过`--hack gcc-lpthread`选项可以实现。

- 2016/09/05: 支持ccache这个编译缓存工具了,重复编译时速度快了很多。选项`--ccache`,注意是两个c。

- 2016/09/06: 编译android-mipsel版时,碰到bits/c++config.h找不到之类的错误。似乎以前碰到过查了一下搞好了,可又忘了。得做个memo。

    c++的bits目录名称实在操蛋!让人误以为是位操作的东西,
    实际里面放得是c++ STL(template)的头文件等东西,而且bits是gnu-libstdc++库里特有名称。
    
    bits目录出现在三个地方:
    ```
    独立toolchain目录/include/c++/4.9.x/       #一般的c++的.h文件,但是没有STL的.h文件。
    独立toolchain目录/include/c++/4.9.x/bits/  #STL的.h文件
    独立toolchain目录/include/c++/4.9.x/mipsel-linux-android/bits  #子构架关联的.h文件。
    ```
    第一个目录是c++编译器默认的包含目录,自然其下的bits/xxx可以用include <bits/xxx>。但是第三个目录就不行了。
    
    一般情况下写个文件a.cc
    ```
    #include <functional>  #这个里面#include <bits/c++config.h>了。
    ```
    然后调用toolchain里的`g++ -c -o a.o a.cc`是好好的,会自动子构架目录里的c++config.h。
    用`g++ -E a.cc`可以看到c++config.h从哪里来的。
    
    V8里默认添加了一个`-mips32r2`给g++,表示生成CPU为mips32r2的代码,
    
    结果g++不干了,报错说找不到bits/c++config.h。这应该是g++自己的毛病。
    
    所以在mips构架里,android-gcc-toolchain把这些文件子构架里的.h都copy到标准的bits目录下去了。
