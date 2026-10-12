$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
try {
    $adapters = @(Get-NetAdapter | Where-Object { $_.InterfaceDescription -match 'Radmin|Famatech' })
    if ($adapters.Count -eq 0) { throw '请先安装 Radmin VPN，再运行此脚本。' }
    $admin = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (!$admin) {
        Write-Host '需要管理员权限添加茶杯头的 UDP 47777 入站规则，范围只限 Radmin VPN 虚拟网卡。'
        $elevated = Start-Process -FilePath 'powershell.exe' -Verb RunAs -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',('"' + $PSCommandPath + '"') -Wait -PassThru
        if ($elevated.ExitCode -ne 0) { throw '防火墙规则未创建。请查看 Online-Tools\firewall-setup.log。' }
        Write-Host '茶杯头联机防火墙规则已配置。'
        exit 0
    }
    $program = Join-Path $PSScriptRoot 'Cuphead.exe'
    if (!(Test-Path -LiteralPath $program)) { throw '请把此脚本放在 Cuphead.exe 所在目录。' }
    $ruleName = 'CupheadCoop-Radmin-UDP-47777'
    $existing = Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue
    if ($existing) { Remove-NetFirewallRule -Name $ruleName }
    New-NetFirewallRule -Name $ruleName -DisplayName 'Cuphead Co-op via Radmin VPN (UDP 47777)' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 47777 -Program $program -InterfaceAlias $adapters.Name -RemoteAddress '26.0.0.0/8' -Profile Any | Out-Null
    'Created: UDP 47777; Cuphead.exe; Radmin adapter; remote 26.0.0.0/8.' | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'Online-Tools\firewall-setup.log')
    Write-Host '茶杯头联机防火墙规则已配置。'
} catch {
    $errorMessage = $_.Exception.Message
    if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'Online-Tools')) { $errorMessage | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'Online-Tools\firewall-setup.log') }
    Write-Host $errorMessage -ForegroundColor Red
    exit 1
}
