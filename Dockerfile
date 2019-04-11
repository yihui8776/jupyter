FROM ubuntu:16.04
MAINTAINER yihui8776 <wangyaohui8776@sina.com>

#安装依赖
RUN apt-get update
RUN apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev  libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev  xz-utils tk-dev vim openssh-server zlib*  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#python3.7
RUN wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz  && \
    tar -zxvf Python-3.7.0.tgz  && \
    cd Python-3.7.0/  && \
    ./configure prefix=/usr/local/python37 && \
    make && make install && \
    mv /usr/bin/python3 /usr/bin/python3.bak && \
    #mv /usr/bin/pip3  /usr/bin/pip3.bak && \
    ln -s /usr/local/python37/bin/python3 /usr/bin/python3  && \
    ln -s /usr/local/python37/bin/pip3 /usr/bin/pip3 

#jupyter
RUN pip3 install jupyter  && ln -s /usr/local/python37/bin/jupyter /usr/bin/jupyter

# SSH Server
RUN sed -i 's/^\(PermitRootLogin\).*/\1 yes/g' /etc/ssh/sshd_config && \
    sed -i 's/^PermitEmptyPasswords .*/PermitEmptyPasswords yes/g' /etc/ssh/sshd_config && \
    echo 'root:ai1234' > /tmp/passwd && \
    chpasswd < /tmp/passwd && \
    rm -rf /tmp/passwd

# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
COPY notebooks /notebooks

# Jupyter has issues with being run directly:
# We just add a little wrapper script.
COPY run_jupyter.sh /
RUN chmod +x  /run_jupyter.sh
RUN chmod +x /notebooks

# IPython
EXPOSE 8888
# SSH
EXPOSE 22

WORKDIR "/notebooks"

CMD ["/run_jupyter.sh", "--allow-root"]        
