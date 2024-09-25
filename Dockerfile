FROM ubuntu:18.04

ENV PATH="/root/bake/build/bin:/root/bake/build/bin_dce:${PATH}"
ENV LD_LIBRARY_PATH="/root/bake/build/lib:${LD_LIBRARY_PATH}"
ENV DCE_PATH="/root/bake/build/bin_dce:/root/bake/build/sbin:${DCE_PATH}"

RUN apt-get update -y && apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get install -y g++ cmake ninja-build ccache libgsl-dev libgtk-3-dev libboost-dev \
                       wget git python3 python3-pip automake bc bison flex gawk libc6 libc6-dbg \
                       libdb-dev libssl-dev libpcap-dev vim rsync gdb mercurial indent libsysfs-dev tmux

RUN pip3 install requests distro

RUN git clone https://gitlab.com/nsnam/bake.git /root/bake
WORKDIR /root/bake

RUN ./bake.py configure -e dce-ns3-1.11

RUN ./bake.py download
RUN ./bake.py download -o iputils

COPY ./dce-global-variables.cc /root/bake/source/ns-3-dce/model

RUN ./bake.py build -o iputils
RUN ./bake.py build

RUN mkdir /root/bake/source/ns-3-dce/myscripts/simulacion
COPY ./wscript /root/bake/source/ns-3-dce/myscripts/simulacion
COPY ./simulacion.cc /root/bake/source/ns-3-dce/myscripts/simulacion
