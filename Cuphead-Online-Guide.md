# 茶杯头异地双人联机

适用：Windows 电脑，Cuphead 1.3.4，两台电脑各自运行游戏。此包使用 CupheadCoop 1.2.0 的本地修正版 1.2.0.1，通过 UDP 同步输入和游戏状态。

## 一次性准备

1. 朋友把 `Cuphead-Online-Public.zip` 解压到他自己的 `Cuphead.exe` 所在目录。两台电脑必须使用这份相同的联机包及相同游戏版本。
2. 两个人分别双击 `Setup-Online-Tools.bat`，按官方安装程序提示安装 Radmin VPN。安装虚拟网卡需要 Windows 管理员确认。
3. 主机在 Radmin VPN 中点击“创建网络”，设置网络名和密码；朋友点击“加入网络”，输入主机提供的网络名和密码。
4. 在 Radmin VPN 中看到对方在线后，主机双击 `Allow-Cuphead-Online.bat`，允许 Windows 管理员确认。此脚本只添加本游戏 UDP 47777 的入站规则，限定 Radmin VPN 网卡和虚拟 IP 范围。

## 每次游玩

1. 两人保持 Radmin VPN 在线。
2. 主机双击 `Start-Cuphead-Host.bat`。启动约 5 秒后自动等待连接，把 Radmin VPN 显示的 `26.x.x.x` 虚拟 IP 发给朋友。
3. 朋友双击 `Start-Cuphead-Join.bat`，输入主机虚拟 IP。连接成功后，状态显示 `mode=Client`、`handshake ok`。
4. 主机选择存档并进入关卡，朋友控制二号玩家。两人都使用各自电脑上的正常一号玩家按键或手柄。
5. `O` 显示／隐藏联机状态；`F11` 断开。结束联机后关闭游戏，再启动单人模式。

需要重新尝试连接时，先按 `F11`，主机按 `F9`，朋友按 `F10`。

## 单人模式

双击 `Start-Cuphead-Local.bat`。该脚本在本次启动中禁用模组加载，保留之前的本地启动方式。

## 已知范围

- 使用主机的关卡流程，进度以主机为准；此包不在两台电脑间复制存档。
- 模组属于实验性实现。它没有官方在线模式的完整兼容保证，尚未逐一实测所有 Boss、DLC、地图交互及通关结算。
- 本机双实例测试用于验证握手、输入数据、双角色状态及关卡加载；真实异地连接仍需朋友电脑加入网络后验证。
- 如果一直连接不上，先用 Radmin VPN 的右键“Ping”检查双方互通，然后确认主机已运行防火墙配置、双方游戏和模组版本相同。
- 查看 `BepInEx/LogOutput.log` 可确认模组加载及连接状态。正常联机不需要开启配置里的 Debug 自动游玩项。

## 来源与本地修正

- 模组源码及原始版本：https://github.com/LeifsterNYC/cuphead-coop ，基于 v1.2.0（提交 `2daf322785512d83a6c842fc51da7d88b262c1e8`）。
- 加载器：BepInEx 5.4.23.5 官方 Windows x64 包，https://github.com/BepInEx/BepInEx/releases/tag/v5.4.23.5 。
- Radmin VPN 2.1.4951.1 安装包来自 https://www.radmin-vpn.com/ ，已核验 Famatech 数字签名有效。
- 本地修正：客户端使用 Cuphead 原生关卡加载流程准备资源；停止客户端 Boss 协程及动画事件重复触发的本地攻击；断开时恢复记录的动画事件设置。
- 原始游戏程序与资源不包含在朋友安装包里。

## 公开版连接配置

主机和加入方都应安装此公开版包。公开版使用统一默认连接配置，与之前单独生成的私人朋友包不同；混用时需让双方配置中的 ConnectKey 保持一致。创建 Radmin VPN 网络时，请自行设置该网络的名称和密码。