# docker-centos9

CentOS Stream 9 Docker 镜像

## 构建镜像

```bash
git clone https://github.com/fifilyu/docker-centos9.git
cd docker-centos9
sh build.sh
```

## 使用方法

### 启动一个容器很简单

```bash
docker run -d \
    --env LANG=en_US.UTF-8 \
    --env TZ=Asia/Shanghai \
    --name centos9 \
    fifilyu/centos9:latest
```

显示容器 IP：

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' centos9
```

查看 `root` 用户随机密码：

```bash
docker logs centos9
```

SSH 远程连接：

```bash
ssh root@容器IP -v
```

### 启动带公钥的容器

```bash
docker run -d \
    --env LANG=en_US.UTF-8 \
    --env TZ=Asia/Shanghai \
    --env PUBLIC_STR="$(<~/.ssh/fifilyu@archlinux.pub)" \
    --name centos9_key \
    fifilyu/centos9:latest
```

效果同上。另外，可以通过 SSH 无密码登录容器。

`$(<~/.ssh/fifilyu@archlinux.pub)` 表示在命令行读取文件内容到变量。

`PUBLIC_STR="$(<~/.ssh/fifilyu@archlinux.pub)"` 也可以写作：

    PUBLIC_STR="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLGJVJI1Cqr59VH1NVQgPs08n7e/HRc2Q8AUpOWGoJpVzIgjO+ipjqwnxh3eiBd806eXIIa5OFwRm0fYfMFxBOdo3l5qGtBe82PwTotdtpcacP5Dkrn+HZ1kG+cf0BNSF5oXbTCTrqY12/T8h4035BXyRw7+MuVPiCUhydYs3RgsODA47ZR3owgjvPsayUd5MrD8gidGqv1zdyW9nQXnXB7m9Sn9Mg8rk6qBxQUbtMN9ez0BFrUGhXCkW562zhJjP5j4RLVfvL2N1bWT9EoFTCjk55pv58j+PTNEGUmu8PrU8mtgf6zQO871whTD8/H6brzaMwuB5Rd5OYkVir0BXj fifilyu@archlinux"

### 启动容器时映射端口

```bash
docker run -d \
    --env LANG=en_US.UTF-8 \
    --env TZ=Asia/Shanghai \
    -p 1022:22 \
    --name centos9_port \
    fifilyu/centos9:latest
```

执行 `ssh root@127.0.0.1 -p 1022 -v` 测试 SSH 端口状态

## 自定义设置

自定义配置参数，可以直接通过 Docker 命令进入 bash 编辑：

`docker exec -it 容器名称 bash`

或者通过 SSH+私钥方式连接容器的 22 端口：

`ssh root@容器IP`

## 镜像变更内容

### 新增 Yum 源

- epel

### 开放端口

- SSHD->22（通过 SSH+私钥方式连接容器的 22 端口，方便查看日志）

### 启动服务

- OpenSSH Daemon（sshd）

### 文件列表

- /etc/ssh/sshd_config
- /etc/ssh/ssh_host_rsa_key
- /etc/ssh/ssh_host_ecdsa_key
- /etc/ssh/ssh_host_ed25519_key
- /etc/security/limits.conf
- /etc/yum.conf
- /etc/selinux/config
- /etc/profile.d/python3.sh
- /usr/local/bin/jq
- /usr/local/python3
- /usr/local/python-3.12.2
- /root/.ssh/authorized_keys

### 软件包

#### Python

- python312

#### 命令行编辑工具

- xmlstarlet（xml）
- crudini（ini）
- jq（json）
- yq（yaml）
- toml-cli（toml）

#### 常用工具

- bash-completion
- bzip2
- curl
- iproute
- mlocate
- openssh-clients
- openssh-server
- pwgen
- rsync
- screen
- tar
- tcpdump
- telnet
- tree
- unzip
- vim-enhanced
- wget
- xz
- dnf-utils
