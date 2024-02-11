FROM dokken/centos-stream-9:latest

ENV TZ Asia/Shanghai
ENV LANG en_US.UTF-8

##############################################
# buildx有缓存，注意判断目录或文件是否已经存在
##############################################

####################
# 设置DNF
####################
RUN grep '*.i386 *.i586 *.i686' /etc/dnf.conf || echo "exclude=*.i386 *.i586 *.i686" >> /etc/dnf.conf
RUN dnf update -y
RUN dnf install -y epel-release
RUN dnf makecache

####################
# 更新系统软件包
####################
RUN dnf update -y

####################
# 安装常用软件包
####################
RUN dnf install -y iproute rsync dnf-utils tree pwgen vim-enhanced wget curl screen bzip2 tcpdump unzip tar xz bash-completion telnet chrony sudo strace openssh-server openssh-clients mlocate

RUN grep 'set fencs=utf-8,gbk' /etc/vimrc || echo 'set fencs=utf-8,gbk' >>/etc/vimrc

####################
# 设置文件句柄
####################
RUN grep '*               soft   nofile            65535' /etc/security/limits.conf || echo "*               soft   nofile            65535" >> /etc/security/limits.conf
RUN grep '*               hard   nofile            65535' /etc/security/limits.conf || echo "*               hard   nofile            65535" >> /etc/security/limits.conf

####################
# 关闭SELINUX
####################
RUN echo SELINUX=disabled>/etc/selinux/config
RUN echo SELINUXTYPE=targeted>>/etc/selinux/config

####################
# 配置SSH
####################
RUN mkdir -p /root/.ssh
RUN touch /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys
COPY file/etc/ssh/sshd_config /etc/ssh/sshd_config

RUN ssh-keygen -t rsa -b 2048 -N '' -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t ecdsa -b 256 -N '' -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t ed25519 -b 256 -N '' -f /etc/ssh/ssh_host_ed25519_key

####################
# 安装Python3.11
####################
RUN dnf install -y tcl tk xz zlib openssl

###########################
## 安装Python312
###########################
COPY file/usr/local/python-3.12.2/ /usr/local/python-3.12.2/
WORKDIR /usr/local
RUN test -L python3 || ln -s python-3.12.2 python3

ARG py_bin_dir=/usr/local/python3/bin
RUN echo "export PATH=${py_bin_dir}:\${PATH}" > /etc/profile.d/python3.sh

WORKDIR ${py_bin_dir}
RUN test -L pip312 || ln -v -s pip3 pip312
RUN test -L python312 || ln -v -s python3 python312

RUN ./pip312 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN ./pip312 install --root-user-action=ignore -U pip

####################
# 安装常用编辑工具
####################
RUN ./pip312 install --root-user-action=ignore -U yq toml-cli

COPY file/usr/local/bin/jq /usr/local/bin/jq
RUN chmod 755 /usr/local/bin/jq

RUN dnf install -y xmlstarlet crudini

####################
# BASH设置
####################
RUN echo "alias ll='ls -l --color=auto --group-directories-first'" >> /root/.bashrc

####################
# 清理
####################
RUN rm -f /root/anaconda-ks.cfg /root/anaconda-post-nochroot.log  /root/anaconda-post.log  /root/original-ks.cfg
RUN dnf clean all

####################
# 设置开机启动
####################
COPY file/usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

WORKDIR /root

EXPOSE 22
