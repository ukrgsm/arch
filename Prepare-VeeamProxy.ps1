# Підняти WinRM (дозволяє Veeam виконувати віддалені дії)
Enable-PSRemoting -Force

# Включити правила фаєрвола для WinRM, WMI, SMB
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-29502"      # WMI
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28502"      # File and Printer Sharing
Enable-NetFirewallRule -DisplayGroup "Remote Administration"

# Відкрити порти для Veeam Proxy
New-NetFirewallRule -DisplayName "Veeam Agent TCP 6160" -Direction Inbound -Protocol TCP -LocalPort 6160 -Action Allow
New-NetFirewallRule -DisplayName "Veeam Data TCP 2500-5000" -Direction Inbound -Protocol TCP -LocalPort 2500-5000 -Action Allow

# Дозволити доступ до admin$ для локальних адміністраторів (якщо використовуєш локального юзера)
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
 -Name "LocalAccountTokenFilterPolicy" -PropertyType DWord -Value 1 -Force

# Перезапуск служби WinRM (на всякий випадок)
Restart-Service WinRM

Write-Host "`n✅ Сервер підготовлено для Veeam Proxy!" -ForegroundColor Green

#Set-ExecutionPolicy RemoteSigned -Scope Process
#.\Prepare-VeeamProxy.ps1

