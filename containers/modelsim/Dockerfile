
FROM ubuntu:22.04

# ARG version_modelsim="20.1.1"
# RUN version_modelsim_std=$(echo "$version_modelsim" | sed 's/\([0-9]\+\)\.\([0-9]\)/\std\.\2/')
# ARG build_modelsim="720"

# ARG bin_modelsim="ModelSimSetup-${version_modelsim}.${build_modelsim}-linux.run"
# ARG url_donwload_modelsim="http://download.altera.com/akdlm/software/acdsinst/${version_modelsim_std}/${build_modelsim}/ib_installers/${bin_modelsim}"
# ARG path_install_modelsim="/tmp"
# RUN echo "Modified version: ${version_modelsim_std}"

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    lib32ncurses6 \
    libxft2 \
    libxft2:i386 \
    libxext6 \
    libxext6:i386

COPY ModelSimSetup-20.1.1.720-linux.run .
RUN ./ModelSimSetup-20.1.1.720-linux.run --mode unattended --installdir . --unattendedmodeui none --accept_eula 1
ENV PATH="/modelsim_ase/bin:${PATH}"

RUN rm ModelSimSetup-20.1.1.720-linux.run

