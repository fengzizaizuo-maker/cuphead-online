param(
    [ValidateSet('Host','Join')][string]$Role = 'Host',
    [string]$HostAddress = ''
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
Set-Location -LiteralPath $PSScriptRoot
try {
    foreach ($file in @('Cuphead.exe','winhttp.dll','BepInEx\plugins\CupheadCoop\CupheadCoop.dll','BepInEx\config\leif.cupheadcoop.cfg')) {
        if (!(Test-Path -LiteralPath (Join-Path $PSScriptRoot $file))) { throw ('缺少文件：' + $file + '。请把联机包解压到 Cuphead.exe 所在目录。') }
    }
    if (@(Get-Process -Name Cuphead -ErrorAction SilentlyContinue).Count -gt 0) { throw '请先关闭正在运行的茶杯头，再切换主机／加入模式。' }
    if ($Role -eq 'Join') {
        if ([string]::IsNullOrWhiteSpace($HostAddress)) { $HostAddress = Read-Host '输入主机在 Radmin VPN 中显示的 IPv4 地址' }
        $HostAddress = $HostAddress.Trim()
        $parsedAddress = $null
        if (![Net.IPAddress]::TryParse($HostAddress, [ref]$parsedAddress) -or $parsedAddress.AddressFamily -ne [Net.Sockets.AddressFamily]::InterNetwork) { throw '请输入 IPv4 地址，例如 26.12.34.56。' }
        $autoStart = 'Connect'
    } else {
        $HostAddress = '127.0.0.1'
        $autoStart = 'Host'
    }
    $configPath = Join-Path $PSScriptRoot 'BepInEx\config\leif.cupheadcoop.cfg'
    $configText = [IO.File]::ReadAllText($configPath)
    $networkMatch = [regex]::Match($configText, '(?ms)^\[Network\][ \t]*\r?\n.*?(?=^\[|\z)')
    if (!$networkMatch.Success) { throw '联机配置缺少 Network 段。请重新解压联机包。' }
    $keyMatch = [regex]::Match($networkMatch.Value, '(?m)^ConnectKey\s*=\s*([^\r\n]+)')
    if (!$keyMatch.Success) { throw '联机配置缺少连接密钥。两台电脑需要使用同一份联机包。' }
    $connectKey = $keyMatch.Groups[1].Value.Trim()
    $networkText = @"
[Network]
Transport = Udp
RemoteHost = $HostAddress
Port = 47777
ConnectKey = $connectKey
HostSteamId =
AutoStart = $autoStart

"@
    $configText = $configText.Remove($networkMatch.Index, $networkMatch.Length).Insert($networkMatch.Index, $networkText + "`r`n")
    [IO.File]::WriteAllText($configPath, $configText, [Text.UTF8Encoding]::new($false))
    Remove-Item Env:\DOORSTOP_DISABLE -ErrorAction SilentlyContinue
    if ($Role -eq 'Host') {
        Write-Host '主机模式：游戏启动约 5 秒后自动开始等待连接。'
        $vpnIps = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -match '^26\.' } | Select-Object -ExpandProperty IPAddress)
        if ($vpnIps.Count -gt 0) {
            Write-Host ('把主机虚拟 IP 告诉朋友：' + ($vpnIps -join ', '))
        } else {
            Write-Host '还没有检测到 Radmin VPN 地址。异地联机前请先运行 Setup-Online-Tools.bat，创建网络并让朋友加入。'
        }
        Write-Host '连接建立后由主机选存档、进入关卡；朋友控制二号玩家。'
    } else {
        Write-Host ('正在连接主机 ' + $HostAddress + ':47777；两台电脑需要加入同一个 Radmin VPN 网络。')
    }
    Write-Host 'F11 断开；O 显示／隐藏状态。单人游玩请用 Start-Cuphead-Local.bat。'
    Start-Process -FilePath (Join-Path $PSScriptRoot 'Cuphead.exe') -WorkingDirectory $PSScriptRoot
} catch {
    Write-Host ('启动失败：' + $_.Exception.Message) -ForegroundColor Red
    exit 1
}
