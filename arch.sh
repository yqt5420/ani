

#从这里开始是换源操作，封装成一个函数，让他可以重复执行
## --------------------------pacman操作---------------------------------- ##
## 更换国内源
echo 'start开始换国内源'
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.xjtu.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.shanghaitech.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist

## -------------------------------------------------------------- ##
### 开启multilib仓库支持
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
echo ' ' >> /etc/pacman.conf
## 增加archlinuxcn源
echo '[archlinuxcn]' >> /etc/pacman.conf
echo 'SigLevel = Never' >> /etc/pacman.conf
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
## -------------------------------------------------------------- ##
## 增加arch4edu源
echo '[arch4edu]' >> /etc/pacman.conf
echo 'SigLevel = Never' >> /etc/pacman.conf
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/arch4edu/$arch' >> /etc/pacman.conf
## 开启pacman颜色支持
sed -i 's/#Color/Color/g' /etc/pacman.conf
echo '换源操作结束stop'
# 检查分区是否存在
check_partition() {
    local partition="$1"

    # 使用ls -l命令检查分区是否存在，$devdir是设备目录，通常是/dev
    local devdir=$(dirname "$partition")
    if [ ! -d "$devdir" ] || [ ! -e "$partition" ]; then
        echo "错误：分区设备 $partition 不存在。"
        exit 1
    fi
}

# 确保脚本以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "此脚本必须以root权限运行" 
   exit 1
fi
# 中间还有分区和挂载步骤
#自己用cfdisk分区，
#请输入boot分区、根分区的路径（这里做个交互存在变量里）
# 提示用户输入分区信息
read -p "请输入boot分区的设备路径（例如 /dev/sda1）: " boot_dir
read -p "请输入根分区的设备路径（例如 /dev/sda2）: " root_dir

# 验证分区路径
if [[ -z "$boot_dir" || -z "$root_dir" ]]; then
    echo "错误：分区路径不能为空。"
    exit 1
fi
# 检查用户输入的分区是否存在
check_partition "$boot_dir"
check_partition "$root_dir"

#格式化boot分区
mkfs.fat -F32 "$boot_dir"
#格式化根分区
mkfs.btrfs -f -L aw "$root_dir"
#挂载根分区# 创建 / 目录子卷# 创建 /home 目录子卷
mount -t btrfs -o compress=lzo "$root_dir" /mnt
btrfs subvolume create /mnt/@ 
btrfs subvolume create /mnt/@home 
umount -R /mnt
# 挂载根分区
mount -t btrfs -o subvol=/@,compress=lzo "$root_dir" /mnt
# 挂载 /home 子卷
mount -t btrfs -o subvol=/@home,compress=lzo "$root_dir" /mnt/home
# 挂载 boot 分区
mount "$boot_dir" /mnt/boot




## -------------------------------------------------------------- ##
# 给新系统安装基础软件
pacstrap /mnt base base-devel linux linux-firmware btrfs-progs intel-ucode amd-ucode

# 安装常用软件
pacstrap /mnt networkmanager vim sudo fish git wget nano htop neofetch yay openssh screen wireless-regdb wireless_tools wpa_supplicant cronie wqy-zenhei timeshift grub efibootmgr os-prober 
# 引导程序
  
# 安装中文字体
## -------------------------------------------------------------- ##
# 生成 fstab 文件
genfstab -U /mnt > /mnt/etc/fstab



echo '#############################################################################################################'
echo '安装完成，现在进入arch-chroot开始配置系统'
echo '###############################################################################################################\n'
# 进入 Arch Linux 根文件系统环境
arch-chroot /mnt /bin/bash << 'EOF'
# 在这里执行一些命令，比如安装软件包
echo 'start开始换国内源'
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.xjtu.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
echo 'Server = https://mirrors.shanghaitech.edu.cn/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist

## -------------------------------------------------------------- ##
### 开启multilib仓库支持
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
echo ' ' >> /etc/pacman.conf
## 增加archlinuxcn源
echo '[archlinuxcn]' >> /etc/pacman.conf
echo 'SigLevel = Never' >> /etc/pacman.conf
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
## -------------------------------------------------------------- ##
## 增加arch4edu源
echo '[arch4edu]' >> /etc/pacman.conf
echo 'SigLevel = Never' >> /etc/pacman.conf
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/arch4edu/$arch' >> /etc/pacman.conf
## 开启pacman颜色支持
sed -i 's/#Color/Color/g' /etc/pacman.conf
echo '换源操作结束stop'


#设置系统语言为中文
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# 设置主机名和hosts
echo "aw" > /etc/hostname
echo "127.0.0.1   localhost
::1         localhost
127.0.1.1   aw.localdomain aw" >> /etc/hosts

# 设置时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# 设置 root 密码
echo "root:aw" | chpasswd
usermod -s /bin/fish root 
# 创建用户
useradd -m -G wheel -s /bin/fish aw
echo "aw:aw" | chpasswd
# 给用户添加 sudo 权限
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
echo 'aw ALL= (ALL) NOPASSWD: ALL' >> /etc/sudoers
# 创建用户目录
mkdir -p /home/aw
chown -R aw:aw /home/aw

# 安装引导程序
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
#修改grub配置文件
# modprobe.blacklist=iTCO_wdt
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 nowatchdog"/g' /etc/default/grub
sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
#生成grub配置文件
grub-mkconfig -o /boot/grub/grub.cfg

# 安装gnome桌面环境、ibus输入法
pacman -S --noconfirm gnome sdm ibus-libpinyin 
#安装火狐浏览器
pacman -S --noconfirm firefox firefox-i18n-zh-cn

echo 'Arch基础系统安装完成！'
# 设置开机自启的任务
# 设置网络开机自启
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable cronie
systemctl enable sdm
# 安装archlinuxcn-keyring
pacman -S --noconfirm archlinuxcn-keyring archlinux-keyring arch4edu-keyring


EOF
# 使用 exit 命令退出 arch-chroot 环境
exit
umount -R /mnt


