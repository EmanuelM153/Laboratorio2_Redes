FROM ubuntu:18.04

# Set environment variables persistently
RUN export PATH="/root/bake/build/bin:/root/bake/build/bin_dce:${PATH}"
RUN export LD_LIBRARY_PATH="/root/bake/build/lib:${LD_LIBRARY_PATH}"
RUN export DCE_PATH="/root/bake/build/bin_dce:/root/bake/build/sbin:${DCE_PATH}"

# Ensure that the package lists are updated correctly
RUN apt-get update -y && apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get install -y g++ cmake ninja-build ccache libgsl-dev libgtk-3-dev libboost-dev \
                       wget git python3 python3-pip automake bc bison flex gawk libc6 libc6-dbg \
                       libdb-dev libssl-dev libpcap-dev vim rsync gdb mercurial indent libsysfs-dev

# Install Python dependencies
RUN pip3 install requests distro

# Clone bake and checkout the correct branch
RUN git clone https://gitlab.com/nsnam/bake.git /root/bake
WORKDIR /root/bake

# Configure bake for DCE
RUN ./bake.py configure -e dce-ns3-1.11

# Download the required packages
RUN ./bake.py download

# Build everything
RUN ./bake.py build
