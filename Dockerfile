FROM archlinux:latest

LABEL maintainer="Video Restoration Container"
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# ----------------------------------------------
# --- Update System and install dependencies ---
# ----------------------------------------------
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        base-devel git sudo vim python wget unzip cmake ninja meson nasm yasm \
        vulkan-icd-loader vulkan-radeon vulkan-headers opencl-mesa clinfo \
        python-pip python-numpy python-wheel python-setuptools \
        zlib libjpeg-turbo libpng gcc make pkgconf openssh cython \
        x264 x265 libvpx opus libvorbis lame libfdk-aac libass freetype2 libpng openjpeg2



# ----------------------------------
# --- Install FFmpeg Version 7.1 ---
# ----------------------------------
# Create builder user for makepkg
RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder

# Import Key
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys B18E8928B3948D64 

WORKDIR /tmp
RUN git clone https://aur.archlinux.org/ffmpeg7.1.git /tmp/ffmpeg7.1 && \
        cd /tmp/ffmpeg7.1 && \
        git config --add core.filemode false && \
        chmod -R 777 /tmp/ffmpeg7.1 && \
        makepkg -si --noconfirm

# Back to Root User
USER root

#------------------------------
# --- Install Python vsutil ---
#------------------------------
WORKDIR /tmp
RUN wget https://files.pythonhosted.org/packages/f2/dc/95df63612bd0a95d7a06a1c51dde3ca0f4ae697d9e231c2345390ff9638c/vsutil-0.8.0.tar.gz && \
    tar -xzf vsutil-0.8.0.tar.gz && cd vsutil-0.8.0 && \
    python setup.py install

#----------------------------
# --- Compile VapourSynth ---
#----------------------------
WORKDIR /opt
RUN git clone --recursive https://github.com/vapoursynth/vapoursynth.git && \
    cd vapoursynth && \
    git submodule sync --recursive && \
    git submodule update --init --recursive  && \
    ./autogen.sh && ./configure --prefix=/usr && \
    make -j$(nproc) && make install

#---------------------------------------------
# --- Install IA Tool (Real-ESRGAN e RIFE) ---
#---------------------------------------------
WORKDIR /opt
RUN https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan.git
COPY fix/.gitmodules /opt/Real-ESRGAN-ncnn-vulkan/.gitmodules # Change ssh clone to HTTPS clone
RUN cd Real-ESRGAN-ncnn-vulkan && \
    git submodule update --init --recursive  && \
    mkdir build && cd build && cmake ../src -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && make -j$(nproc) && \
    install -m755 realesrgan-ncnn-vulkan /usr/local/bin/

RUN git clone https://github.com/nihui/rife-ncnn-vulkan.git && \
    cd rife-ncnn-vulkan && \
    git submodule update --init --recursive  && \
    mkdir build && cd build && cmake ../src -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && make -j$(nproc) && \
    install -m755 rife-ncnn-vulkan /usr/local/bin/

#---------------------------------------
# --- Creating folders and structure ---
#---------------------------------------
RUN mkdir -p /workspace/source_videos /workspace/restored_videos /workspace/plugins /workspace/script

#-------------------------------
# --- Copy entrypoint script ---
#-------------------------------
COPY restore.sh /usr/local/bin/restore.sh
RUN chmod +x /usr/local/bin/restore.sh

WORKDIR /workspace

# Default entrypoint - Video restoration
ENTRYPOINT ["/usr/local/bin/restore.sh"]

# Debug
#ENTRYPOINT ["/bin/bash"] # In debug case
