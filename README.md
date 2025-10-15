# AutoDeployTools_For_Docker
## 这个仓库是干嘛的?
1. 为你的计算机安装dorcker环境  
2. 自动部署容器并完成创建普通用户、彩色目录、安装并设置sudo权限等任务  

## 如何使用？
Install_Docker：部署docker的环境和为你的计算机安装Dorcker  
Run [容器名][挂载目录][使用的镜像名或id] 来构建一个容器  

Run 提供--mnt -ssh 两个可选参数  
--mnt: 容器挂载宿主机的/opt ~/.ssh 目录  
--ssh: 容器仅挂载宿主机的~/.ssh目录  

## 使用示例
Run my_ubuntu ~/workspace ubuntu:20.04  
执行后会对ubuntu:20.04这个基础镜像初始化，然后根据初始化后的镜像运行一个容器  
在这个过程中你需要根据提示设置quectel用户的密码  
