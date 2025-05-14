#Set-ExecutionPolicy RemoteSigned -Scope Process
#.\Prepare-VeeamProxy.ps1

# Підготовка Windows Server до роботи як Veeam Proxy

Write-Host "`n🔧 Вмикаємо PowerShell Remoting (WinRM)..." -ForegroundColor Cyan
Enable-PSRemoting -Force

Write-Host "🔐 Дозволяємо доступ до admin$ для локальних акаунтів..." -ForegroundColor Cyan
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
 -Name "LocalAccountTokenFilterPolicy" -PropertyType DWord -Value 1 -Force

Write-Host "🔥 Відкриваємо необхідні порти фаєрвола..." -ForegroundColor Cyan
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-29502"       # WMI
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28502"       # File and Printer Sharing
New-NetFirewallRule -DisplayName "Veeam Agent TCP 6160" -Direction Inbound -Protocol TCP -LocalPort 6160 -Action Allow
New-NetFirewallRule -DisplayName "Veeam Data TCP 2500-5000" -Direction Inbound -Protocol TCP -LocalPort 2500-5000 -Action Allow

Write-Host "🔁 Перезапускаємо службу WinRM..." -ForegroundColor Cyan
Restart-Service WinRM

Write-Host "🛠 Перевіряємо необхідні служби..." -ForegroundColor Cyan
$requiredServices = @("WinRM", "RemoteRegistry", "LanmanServer", "Winmgmt")
foreach ($svc in $requiredServices) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service.Status -ne 'Running') {
        Start-Service $svc
        Write-Host "✅ Служба $svc запущена"
    } else {
        Write-Host "🟢 Служба $svc вже працює"
    }
}

net user VeeamProxyAdmin "StrongPassword123" /add
net localgroup administrators VeeamProxyAdmin /add

Write-Host "`n✅ Сервер успішно підготовлено для Veeam Proxy!" -ForegroundColor Green
