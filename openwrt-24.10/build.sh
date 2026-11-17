#!/bin/bash
# 官方 OpenWrt ImageBuilder 容器内使用的 build.sh
# 官方镜像（openwrt/imagebuilder:*-24.10.8）的 imagebuilder 解压在 /builder 下（工作目录 /builder）
# 注意与 ImmortalWrt 镜像的 /home/build/immortalwrt 区分
set -e

echo "========================================"
echo "Building for profile: $PROFILE"
echo "Rootfs partsize: ${ROOTFS_SIZE:-默认}"
echo "Include Docker: $INCLUDE_DOCKER"
echo "========================================"

# 首次启动脚本目录（workflow 已将仓库 files 目录挂载到 /builder/files）
FILES_DIR="/builder/files"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting build process..."

# 定义所需安装的包列表（均为官方 feed 内软件包）
PACKAGES=""
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn luci-i18n-firewall-zh-cn luci-i18n-base-zh-cn openssh-sftp-server htop curl bash fdisk sshpass hdparm tcpdump-mini lsof block-mount lsblk parted rsync kmod-tun iperf3 kmod-fs-ext4 kmod-usb-storage kmod-fs-exfat kmod-usb-storage-uas unzip smartmontools luci-compat"

# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-app-dockerman luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-app-dockerman"
fi

# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"
# 输出最终软件包列表到宿主机 bin 目录 供 workflow 写入 release 说明
echo "$PACKAGES" > /builder/bin/final-packages.txt

# ROOTFS_SIZE 仅 x86-64 传入（单位 MB），其他设备为空
if [ -n "$ROOTFS_SIZE" ]; then
    make image PROFILE="$PROFILE" PACKAGES="$PACKAGES" FILES="$FILES_DIR" ROOTFS_PARTSIZE="$ROOTFS_SIZE"
else
    make image PROFILE="$PROFILE" PACKAGES="$PACKAGES" FILES="$FILES_DIR"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
