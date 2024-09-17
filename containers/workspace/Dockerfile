FROM ubuntu:22.04

# Install necessary packages, including make and bash-completion
RUN apt-get update && \
    apt-get install -y \
    make \
    bash-completion \
    iverilog \
    gtkwave \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Enable bash completion for all users by editing the bashrc file
RUN echo 'if [ -f /etc/bash_completion ]; then' >> /etc/bash.bashrc && \
    echo '    . /etc/bash_completion' >> /etc/bash.bashrc && \
    echo 'fi' >> /etc/bash.bashrc

# Add custom make completion function to bashrc
RUN echo '_complete_make_target() {' >> /etc/bash.bashrc && \
    echo '    local cur=${COMP_WORDS[COMP_CWORD]}' >> /etc/bash.bashrc && \
    echo '    COMPREPLY=( $(compgen -W "$(make -qp | awk -F'\'':'\'' '\''/^[a-zA-Z0-9][^$#\/\t=]*:/ {print $1}'\'' | sort | uniq)" -- ${cur}) )' >> /etc/bash.bashrc && \
    echo '}' >> /etc/bash.bashrc && \
    echo 'complete -F _complete_make_target make' >> /etc/bash.bashrc

# Set default command to start a bash session
CMD ["/bin/bash"]
