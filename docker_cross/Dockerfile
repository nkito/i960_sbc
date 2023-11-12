FROM ubuntu:22.04
RUN apt-get update && apt-get install -y build-essential wget automake libtool bison flex lv vim gawk 
RUN mkdir /build && cd /build && \
     wget https://ftp.gnu.org/gnu/binutils/binutils-2.21.1.tar.bz2 && \
     wget https://ftp.gnu.org/gnu/gcc/gcc-2.95.3/gcc-core-2.95.3.tar.gz && \
     wget ftp://sourceware.org/pub/newlib/newlib-1.8.2.tar.gz && \
     tar jxf binutils-2.21.1.tar.bz2 && \
     tar zxf gcc-core-2.95.3.tar.gz && \
     tar zxf newlib-1.8.2.tar.gz
RUN cd /build/binutils-2.21.1 && \
    ./configure --target=i960-elf --prefix=/usr/local/cross --disable-nls --disable-werror && \
    make && make install 
RUN export PATH=$PATH:/usr/local/cross/bin && \
    cd /build/gcc-2.95.3 && \
    ln -s ../newlib-1.8.2/newlib . && \
    sed -i.orig -e 's/open (redir, O_WRONLY | O_TRUNC | O_CREAT)/open (redir, O_WRONLY | O_TRUNC | O_CREAT, 0755)/' gcc/collect2.c && \
    sed -i.orig '1685i tmake_file=i960/t-960bare' gcc/configure.in && \
    cd gcc && autoconf && sed -i.orig -e 's/ac_build_alias=$build_alias/ac_build_alias=i386-pc-linux/' configure && \
    mkdir -p /build/gcc_build/gcc && cd /build/gcc_build && \
    /build/gcc-2.95.3/configure --target=i960-elf --prefix=/usr/local/cross  \
        --disable-nls --disable-threads --disable-shared --host=i386-pc-linux --disable-target-libiberty \
        --enable-languages=c --with-newlib && \
    touch /build/gcc_build/gcc/gcc.info && \
    touch /build/gcc_build/gcc/cpp.info && \
    make && make install 
RUN mkdir /src && echo PS1=\"\\h:\\w\\$ \" >> /etc/bash.bashrc
ENV PATH="/usr/local/cross/bin:${PATH}"
#RUN useradd -m build && apt-get install sudo
#USER build
ENTRYPOINT ["bash"]