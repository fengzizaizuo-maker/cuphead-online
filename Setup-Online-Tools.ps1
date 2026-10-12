$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
try {
    $installer = Join-Path $PSScriptRoot 'Online-Tools\Radmin_VPN_2.1.4951.1.exe'
    if (!(Test-Path -LiteralPath $installer)) { throw '未找到 Radmin VPN 安装包。请从 https://www.radmin-vpn.com/ 下载。' }
    $signature = Get-AuthenticodeSignature -LiteralPath $installer
    if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'Famatech') { throw '安装包签名校验失败。' }
    Write-Host '正在打开 Radmin VPN 官方安装程序。它需要安装虚拟网卡，Windows 可能请求管理员确认。'
    Start-Process -FilePath $installer -Wait
    Write-Host '安装后：你点击“创建网络”，设置网络名和密码；朋友安装后点击“加入网络”，输入同一组信息。'
    Write-Host '在 Radmin VPN 中能看到双方后，主机运行 Allow-Cuphead-Online.bat，再运行 Start-Cuphead-Host.bat。'
    Write-Host '朋友运行 Start-Cuphead-Join.bat，输入你的 Radmin VPN 虚拟 IP。'
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
