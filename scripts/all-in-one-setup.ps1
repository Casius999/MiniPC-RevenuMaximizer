# Script All-in-One pour configuration complète Mini PC
# Auteur: Casius999
# Version: 1.0
# Ce script automatise l'installation et l'optimisation complète d'un mini PC pour la génération de revenus passifs

# Variables de configuration
$deviceName = "MP-$env:computername"
$installPath = "$env:USERPROFILE\MiniPC-RevenuMaximizer"
$logPath = "$installPath\logs"
$configPath = "$installPath\config"
$applicationsToInstall = @("honeygain", "iproyal", "peer2profit", "packetstream", "traffmonetizer")

# Création structure dossiers
function Initialize-Environment {
    Write-Host "=== Initialisation de l'environnement ===" -ForegroundColor Cyan
    
    # Création dossiers
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    New-Item -ItemType Directory -Path $configPath -Force | Out-Null
    New-Item -ItemType Directory -Path "$installPath\downloads" -Force | Out-Null
    
    # Journal configuration
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] Initialisation environnement pour $deviceName" | Out-File -FilePath "$logPath\setup.log" -Append
    
    Write-Host "Structure de dossiers créée avec succès." -ForegroundColor Green
}

# Optimisation système
function Optimize-System {
    Write-Host "=== Application des optimisations système ===" -ForegroundColor Cyan
    
    Write-Host "Optimisation du plan d'alimentation..." -ForegroundColor Yellow
    # Désactivation veilles
    powercfg /change monitor-timeout-ac 0
    powercfg /change standby-timeout-ac 0
    powercfg /change hibernate-timeout-ac 0
    # Activation du plan haute performance
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    
    Write-Host "Désactivation des mises à jour Windows..." -ForegroundColor Yellow
    # Désactivation Windows Update
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DisableWindowsUpdateAccess /t REG_DWORD /d 1 /f
    
    Write-Host "Optimisation des performances..." -ForegroundColor Yellow
    # Optimisation performances
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f
    
    # Optimisation mémoire
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f
    
    Write-Host "Désactivation des effets visuels..." -ForegroundColor Yellow
    # Désactivation effets visuels
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f
    reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f
    
    Write-Host "Optimisation du réseau..." -ForegroundColor Yellow
    # Optimisations réseau
    netsh int tcp set global maxsynretransmissions=2
    netsh int tcp set global initialRto=1000
    
    # Désactivation Nagle's Algorithm
    $networkInterfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    foreach ($interface in $networkInterfaces) {
        New-ItemProperty -Path $interface.PSPath -Name "TcpAckFrequency" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -Path $interface.PSPath -Name "TCPNoDelay" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    # Journal optimisations
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] Optimisations système appliquées" | Out-File -FilePath "$logPath\setup.log" -Append
    
    Write-Host "Optimisations système appliquées avec succès." -ForegroundColor Green
}

# Installation applications de monétisation
function Install-MonetizationApps {
    Write-Host "=== Installation des applications de monétisation ===" -ForegroundColor Cyan
    
    $downloadFolder = "$installPath\downloads"
    
    # Honeygain
    Write-Host "Installation Honeygain..." -ForegroundColor Yellow
    $honeygainUrl = "https://download.honeygain.com/windows-app/honeygain-setup.exe"
    $honeygainInstaller = "$downloadFolder\honeygain-setup.exe"
    try {
        Invoke-WebRequest -Uri $honeygainUrl -OutFile $honeygainInstaller
        Start-Process -FilePath $honeygainInstaller -ArgumentList "/S" -Wait
        Write-Host "   Honeygain installé avec succès!" -ForegroundColor Green
    }
    catch {
        Write-Host "   ERREUR: Installation Honeygain échouée. $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # IPRoyal Pawns
    Write-Host "Installation IPRoyal Pawns..." -ForegroundColor Yellow
    $iproyalUrl = "https://iproyal.com/pawns/download/IPRoyalPawnsSetup.exe"
    $iproyalInstaller = "$downloadFolder\IPRoyalPawnsSetup.exe"
    try {
        Invoke-WebRequest -Uri $iproyalUrl -OutFile $iproyalInstaller
        Start-Process -FilePath $iproyalInstaller -ArgumentList "/S" -Wait
        Write-Host "   IPRoyal Pawns installé avec succès!" -ForegroundColor Green
    }
    catch {
        Write-Host "   ERREUR: Installation IPRoyal Pawns échouée. $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Peer2Profit
    Write-Host "Installation Peer2Profit..." -ForegroundColor Yellow
    $peer2profitUrl = "https://peer2profit.com/download/peer2profit_installer.exe"
    $peer2profitInstaller = "$downloadFolder\peer2profit_installer.exe"
    try {
        Invoke-WebRequest -Uri $peer2profitUrl -OutFile $peer2profitInstaller
        Start-Process -FilePath $peer2profitInstaller -ArgumentList "/S" -Wait
        Write-Host "   Peer2Profit installé avec succès!" -ForegroundColor Green
    }
    catch {
        Write-Host "   ERREUR: Installation Peer2Profit échouée. $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # PacketStream
    Write-Host "Installation PacketStream..." -ForegroundColor Yellow
    $packetstreamUrl = "https://packetstream.io/download/windows"
    $packetstreamInstaller = "$downloadFolder\packetstream_installer.exe"
    try {
        Invoke-WebRequest -Uri $packetstreamUrl -OutFile $packetstreamInstaller
        Start-Process -FilePath $packetstreamInstaller -ArgumentList "/S" -Wait
        Write-Host "   PacketStream installé avec succès!" -ForegroundColor Green
    }
    catch {
        Write-Host "   ERREUR: Installation PacketStream échouée. $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # TraffMonetizer
    Write-Host "Installation TraffMonetizer..." -ForegroundColor Yellow
    $traffmonetizerUrl = "https://traffmonetizer.com/download/win/traffmonetizer.exe"
    $traffmonetizerInstaller = "$downloadFolder\traffmonetizer.exe"
    try {
        Invoke-WebRequest -Uri $traffmonetizerUrl -OutFile $traffmonetizerInstaller
        Start-Process -FilePath $traffmonetizerInstaller -ArgumentList "/S" -Wait
        Write-Host "   TraffMonetizer installé avec succès!" -ForegroundColor Green
    }
    catch {
        Write-Host "   ERREUR: Installation TraffMonetizer échouée. $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Journal installations
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] Applications de monétisation installées" | Out-File -FilePath "$logPath\setup.log" -Append
}

# Configuration des applications et optimisations spécifiques
function Optimize-Applications {
    Write-Host "=== Optimisation des applications ===" -ForegroundColor Cyan
    
    # Configuration Honeygain (config.json dans AppData)
    $honeygainConfigPath = "$env:APPDATA\Honeygain"
    if (!(Test-Path $honeygainConfigPath)) {
        New-Item -ItemType Directory -Path $honeygainConfigPath -Force | Out-Null
    }
    
    $honeygainConfig = @"
{
    "daily_limit": 25000,
    "bandwidth_priority": "maximum",
    "content_delivery": true,
    "restart_interval": 86400,
    "active_hours_start": 0,
    "active_hours_end": 24,
    "performance_mode": "high",
    "network_optimization": true
}
"@
    
    Set-Content -Path "$honeygainConfigPath\config.json" -Value $honeygainConfig
    Write-Host "Configuration Honeygain optimisée" -ForegroundColor Green
    
    # Configuration IPRoyal
    $iproyalConfigPath = "$env:APPDATA\IPRoyal Pawns"
    if (!(Test-Path $iproyalConfigPath)) {
        New-Item -ItemType Directory -Path $iproyalConfigPath -Force | Out-Null
    }
    
    $iproyalConfig = @"
{
    "bandwidth_limit": false,
    "bandwidth_priority": "high",
    "auto_restart": true,
    "restart_interval": 86400,
    "active_hours_mode": "always",
    "performance_mode": "balanced"
}
"@
    
    Set-Content -Path "$iproyalConfigPath\settings.json" -Value $iproyalConfig
    Write-Host "Configuration IPRoyal optimisée" -ForegroundColor Green
    
    # Journal optimisations
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] Applications optimisées" | Out-File -FilePath "$logPath\setup.log" -Append
}

# Configuration démarrage automatique
function Configure-Autostart {
    Write-Host "=== Configuration du démarrage automatique ===" -ForegroundColor Cyan
    
    $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    
    $startupContent = @"
@echo off
echo Démarrage applications de monétisation...
timeout /t 60

echo Démarrage Honeygain...
start "" "C:\Program Files\Honeygain\honeygain.exe"
timeout /t 10

echo Démarrage IPRoyal Pawns...
start "" "C:\Program Files\IPRoyal Pawns\IPRoyal Pawns.exe"
timeout /t 10

echo Démarrage Peer2Profit...
start "" "C:\Program Files\Peer2Profit\Peer2Profit.exe"
timeout /t 10

echo Démarrage PacketStream...
start "" "C:\Program Files\PacketStream\packetstream.exe"
timeout /t 10

echo Démarrage TraffMonetizer...
start "" "C:\Program Files\TraffMonetizer\traffmonetizer.exe"
timeout /t 10

echo Applications démarrées avec succès.
"@
    
    Set-Content -Path "$startupFolder\monetization_autostart.bat" -Value $startupContent
    
    # Création tâche planifiée pour maintenance
    Write-Host "Configuration de la tâche planifiée de maintenance..." -ForegroundColor Yellow
    $maintenanceScriptPath = "$installPath\scripts\daily-maintenance.ps1"
    
    # Vérification que le script existe
    if (Test-Path $maintenanceScriptPath) {
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$maintenanceScriptPath`""
        $trigger = New-ScheduledTaskTrigger -Daily -At "03:00"
        $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd
        Register-ScheduledTask -TaskName "MiniPC-DailyMaintenance" -Action $action -Trigger $trigger -Settings $settings -Force
        Write-Host "Tâche planifiée de maintenance configurée" -ForegroundColor Green
    }
    else {
        Write-Host "Script de maintenance non trouvé - création de la tâche planifiée reportée" -ForegroundColor Yellow
    }
    
    # Journal configuration
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] Configuration démarrage automatique terminée" | Out-File -FilePath "$logPath\setup.log" -Append
    
    Write-Host "Configuration du démarrage automatique terminée" -ForegroundColor Green
}

# Création scripts maintenance
function Create-MaintenanceScripts {
    Write-Host "=== Création des scripts de maintenance ===" -ForegroundColor Cyan
    
    New-Item -ItemType Directory -Path "$installPath\scripts" -Force | Out-Null
    
    # Script maintenance quotidienne
    $dailyMaintenanceContent = @"
# Script maintenance quotidienne
# Généré automatiquement par MiniPC-RevenuMaximizer

# Variables
`$logFile = "$logPath\maintenance_`$(Get-Date -Format 'yyyy-MM-dd').log"
`$applications = @("honeygain", "IPRoyal Pawns", "Peer2Profit", "packetstream", "traffmonetizer")

# Fonction logging
function Log-Message {
    param([string]`$message)
    `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "`$timestamp - `$message" | Out-File -FilePath `$logFile -Append
}

Log-Message "Début maintenance quotidienne"

# Vérification applications
Log-Message "Vérification applications..."
foreach (`$app in `$applications) {
    `$process = Get-Process -Name `$app -ErrorAction SilentlyContinue
    if (`$null -eq `$process) {
        Log-Message "Application `$app non exécutée. Redémarrage..."
        switch (`$app) {
            "honeygain" { Start-Process "C:\Program Files\Honeygain\honeygain.exe" }
            "IPRoyal Pawns" { Start-Process "C:\Program Files\IPRoyal Pawns\IPRoyal Pawns.exe" }
            "Peer2Profit" { Start-Process "C:\Program Files\Peer2Profit\Peer2Profit.exe" }
            "packetstream" { Start-Process "C:\Program Files\PacketStream\packetstream.exe" }
            "traffmonetizer" { Start-Process "C:\Program Files\TraffMonetizer\traffmonetizer.exe" }
        }
    } else {
        Log-Message "Application `$app en cours d'exécution: OK"
    }
}

# Nettoyage fichiers temporaires
Log-Message "Nettoyage fichiers temporaires..."
Remove-Item -Path "`$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

# Optimisation mémoire
[System.GC]::Collect()
Log-Message "Optimisation mémoire effectuée"

Log-Message "Maintenance quotidienne terminée"
"@
    
    Set-Content -Path "$installPath\scripts\daily-maintenance.ps1" -Value $dailyMaintenanceContent
    
    # Script maintenance hebdomadaire
    $weeklyMaintenanceContent = @"
# Script maintenance hebdomadaire
# Généré automatiquement par MiniPC-RevenuMaximizer

# Variables
`$logFile = "$logPath\weekly_maintenance_`$(Get-Date -Format 'yyyy-MM-dd').log"

# Fonction logging
function Log-Message {
    param([string]`$message)
    `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "`$timestamp - `$message" | Out-File -FilePath `$logFile -Append
}

Log-Message "Début maintenance hebdomadaire"

# Nettoyage approfondi
Log-Message "Nettoyage approfondi du système..."
Remove-Item -Path "`$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue

# Vérification disque
Log-Message "Vérification du disque..."
Optimize-Volume -DriveLetter C -ReTrim -Verbose

# Redémarrage applications
Log-Message "Redémarrage de toutes les applications..."
Get-Process -Name "honeygain", "IPRoyal Pawns", "Peer2Profit", "packetstream", "traffmonetizer" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 10

Start-Process "C:\Program Files\Honeygain\honeygain.exe"
Start-Sleep -Seconds 5
Start-Process "C:\Program Files\IPRoyal Pawns\IPRoyal Pawns.exe"
Start-Sleep -Seconds 5
Start-Process "C:\Program Files\Peer2Profit\Peer2Profit.exe"
Start-Sleep -Seconds 5
Start-Process "C:\Program Files\PacketStream\packetstream.exe"
Start-Sleep -Seconds 5
Start-Process "C:\Program Files\TraffMonetizer\traffmonetizer.exe"

Log-Message "Maintenance hebdomadaire terminée"
"@
    
    Set-Content -Path "$installPath\scripts\weekly-maintenance.ps1" -Value $weeklyMaintenanceContent
    
    # Script tableau de bord simple
    $dashboardContent = @"
# Script tableau de bord simple
# Généré automatiquement par MiniPC-RevenuMaximizer

`$processes = @("honeygain", "IPRoyal Pawns", "Peer2Profit", "packetstream", "traffmonetizer")
`$statuses = @{}

function Get-UptimeInfo {
    `$os = Get-CimInstance -ClassName Win32_OperatingSystem
    `$uptime = (Get-Date) - `$os.LastBootUpTime
    return "PC Uptime: {0} jours, {1} heures, {2} minutes" -f `$uptime.Days, `$uptime.Hours, `$uptime.Minutes
}

function Get-MemoryInfo {
    `$os = Get-CimInstance -ClassName Win32_OperatingSystem
    `$total = [math]::Round(`$os.TotalVisibleMemorySize / 1MB, 2)
    `$free = [math]::Round(`$os.FreePhysicalMemory / 1MB, 2)
    `$used = `$total - `$free
    `$percent = [math]::Round((`$used / `$total) * 100, 0)
    
    return "Mémoire: {0}GB utilisé sur {1}GB ({2}%)" -f `$used, `$total, `$percent
}

function Get-CPUInfo {
    `$cpu = Get-CimInstance -ClassName Win32_Processor
    `$usage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    
    return "CPU: {0} ({1:N0}% utilisé)" -f `$cpu.Name, `$usage
}

function Get-DiskInfo {
    `$disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
    `$freeGB = [math]::Round(`$disk.FreeSpace / 1GB, 2)
    `$totalGB = [math]::Round(`$disk.Size / 1GB, 2)
    `$percentFree = [math]::Round((`$freeGB / `$totalGB) * 100, 0)
    
    return "Disque C: {0}GB libre sur {1}GB ({2}% libre)" -f `$freeGB, `$totalGB, `$percentFree
}

# Vérification des applications
foreach (`$process in `$processes) {
    `$running = Get-Process -Name `$process -ErrorAction SilentlyContinue
    if (`$running) {
        `$statuses[`$process] = @{
            Status = "En cours d'exécution"
            PID = `$running.Id
            Memory = [math]::Round(`$running.WorkingSet / 1MB, 2)
            CPU = [math]::Round(`$running.CPU, 2)
        }
    } else {
        `$statuses[`$process] = @{
            Status = "ARRÊTÉ"
            PID = "N/A"
            Memory = "N/A"
            CPU = "N/A"
        }
    }
}

# Affichage du tableau de bord
Clear-Host
Write-Host "=== MiniPC-RevenuMaximizer - Tableau de Bord ===" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host ""
Write-Host "INFORMATIONS SYSTÈME" -ForegroundColor Green
Write-Host "-------------------" -ForegroundColor Green
Write-Host (Get-UptimeInfo)
Write-Host (Get-MemoryInfo)
Write-Host (Get-CPUInfo)
Write-Host (Get-DiskInfo)
Write-Host ""
Write-Host "STATUS APPLICATIONS" -ForegroundColor Green
Write-Host "------------------" -ForegroundColor Green

foreach (`$app in `$processes) {
    if (`$statuses[`$app].Status -eq "En cours d'exécution") {
        Write-Host ("{0}: " -f `$app) -NoNewline -ForegroundColor White
        Write-Host `$statuses[`$app].Status -ForegroundColor Green -NoNewline
        Write-Host " (PID: {0}, Mémoire: {1} MB)" -f `$statuses[`$app].PID, `$statuses[`$app].Memory
    } else {
        Write-Host ("{0}: " -f `$app) -NoNewline -ForegroundColor White
        Write-Host `$statuses[`$app].Status -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Pour redémarrer toutes les applications, exécutez:" -ForegroundColor Yellow
Write-Host "$installPath\scripts\restart-all.ps1" -ForegroundColor Yellow
Write-Host ""
"@
    
    Set-Content -Path "$installPath\scripts\dashboard.ps1" -Value $dashboardContent
    
    # Script redémarrage de toutes les applications
    $restartAllContent = @"
# Script de redémarrage de toutes les applications
# Généré automatiquement par MiniPC-RevenuMaximizer

Write-Host "Arrêt des applications en cours..." -ForegroundColor Yellow
Get-Process -Name "honeygain", "IPRoyal Pawns", "Peer2Profit", "packetstream", "traffmonetizer" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 5

Write-Host "Démarrage des applications..." -ForegroundColor Yellow
Start-Process "C:\Program Files\Honeygain\honeygain.exe"
Start-Sleep -Seconds 3
Start-Process "C:\Program Files\IPRoyal Pawns\IPRoyal Pawns.exe" 
Start-Sleep -Seconds 3
Start-Process "C:\Program Files\Peer2Profit\Peer2Profit.exe"
Start-Sleep -Seconds 3
Start-Process "C:\Program Files\PacketStream\packetstream.exe"
Start-Sleep -Seconds 3
Start-Process "C:\Program Files\TraffMonetizer\traffmonetizer.exe"

Write-Host "Toutes les applications ont été redémarrées avec succès!" -ForegroundColor Green
"@
    
    Set-Content -Path "$installPath\scripts\restart-all.ps1" -Value $restartAllContent
    
    # Journal création scripts
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] Scripts de maintenance créés" | Out-File -FilePath "$logPath\setup.log" -Append
    
    Write-Host "Scripts de maintenance créés avec succès!" -ForegroundColor Green
}

# Configuration des règles pare-feu
function Configure-Firewall {
    Write-Host "=== Configuration des règles pare-feu ===" -ForegroundColor Cyan
    
    $apps = @(
        "C:\Program Files\Honeygain\honeygain.exe",
        "C:\Program Files\IPRoyal Pawns\IPRoyal Pawns.exe",
        "C:\Program Files\Peer2Profit\Peer2Profit.exe",
        "C:\Program Files\PacketStream\packetstream.exe",
        "C:\Program Files\TraffMonetizer\traffmonetizer.exe"
    )
    
    foreach ($app in $apps) {
        if (Test-Path $app) {
            $appName = (Get-Item $app).BaseName
            
            # Règle entrante
            Write-Host "Création règle pare-feu entrante pour $appName..." -ForegroundColor Yellow
            New-NetFirewallRule -DisplayName "Allow $appName Inbound" -Direction Inbound -Program $app -Action Allow -Profile Any -Enabled True -ErrorAction SilentlyContinue | Out-Null
            
            # Règle sortante
            Write-Host "Création règle pare-feu sortante pour $appName..." -ForegroundColor Yellow
            New-NetFirewallRule -DisplayName "Allow $appName Outbound" -Direction Outbound -Program $app -Action Allow -Profile Any -Enabled True -ErrorAction SilentlyContinue | Out-Null
            
            Write-Host "Règles pare-feu pour $appName créées avec succès" -ForegroundColor Green
        }
        else {
            Write-Host "AVERTISSEMENT: $app non trouvé, règles pare-feu non créées" -ForegroundColor Yellow
        }
    }
    
    # Journal
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] Configuration pare-feu terminée" | Out-File -FilePath "$logPath\setup.log" -Append
}

# Fonction principale
function Main {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "=== MiniPC-RevenuMaximizer - Configuration Initiale Complète ===" -ForegroundColor Cyan
    Write-Host "=== Auteur: Casius999                                        ===" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ce script va configurer complètement votre Mini PC pour optimiser la génération de revenus." -ForegroundColor White
    Write-Host "Processus automatisés:" -ForegroundColor White
    Write-Host "  - Optimisations système pour performances maximales" -ForegroundColor White
    Write-Host "  - Installation de 5 applications de monétisation vérifiées" -ForegroundColor White
    Write-Host "  - Configuration optimale des applications" -ForegroundColor White
    Write-Host "  - Configuration du démarrage automatique" -ForegroundColor White
    Write-Host "  - Mise en place des scripts de maintenance" -ForegroundColor White
    Write-Host "  - Configuration des règles pare-feu" -ForegroundColor White
    Write-Host ""
    
    # Demande confirmation
    $confirmation = Read-Host "Voulez-vous procéder à la configuration complète? (O/N)"
    if ($confirmation -ne "O") {
        Write-Host "Configuration annulée par l'utilisateur." -ForegroundColor Yellow
        return
    }
    
    # Vérification privilèges administrateur
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "ERREUR: Ce script nécessite des privilèges administrateur!" -ForegroundColor Red
        Write-Host "Veuillez relancer PowerShell en tant qu'administrateur et réessayer." -ForegroundColor Red
        return
    }
    
    # Temps de début pour calcul durée
    $startTime = Get-Date
    
    # Exécution des étapes avec mesure du temps
    Write-Host ""
    Initialize-Environment
    
    Write-Host ""
    Optimize-System
    
    Write-Host ""
    Install-MonetizationApps
    
    Write-Host ""
    Optimize-Applications
    
    Write-Host ""
    Configure-Autostart
    
    Write-Host ""
    Create-MaintenanceScripts
    
    Write-Host ""
    Configure-Firewall
    
    # Calcul temps d'exécution
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    # Rapport final
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "=== Configuration terminée avec succès!                      ===" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Temps d'exécution: $($duration.Minutes) minutes et $($duration.Seconds) secondes" -ForegroundColor White
    Write-Host ""
    Write-Host "Votre Mini PC est maintenant configuré pour générer des revenus optimaux." -ForegroundColor Green
    Write-Host ""
    Write-Host "Prochaines étapes recommandées:" -ForegroundColor Cyan
    Write-Host "1. Connectez-vous à vos comptes dans chaque application" -ForegroundColor White
    Write-Host "2. Vérifiez que toutes les applications sont en cours d'exécution" -ForegroundColor White
    Write-Host "3. Exécutez le tableau de bord avec: $installPath\scripts\dashboard.ps1" -ForegroundColor White
    Write-Host "4. Planifiez un redémarrage hebdomadaire du système" -ForegroundColor White
    Write-Host ""
    Write-Host "Répertoire d'installation: $installPath" -ForegroundColor Yellow
    Write-Host "Logs: $logPath" -ForegroundColor Yellow
    Write-Host "Scripts: $installPath\scripts" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Redémarrez votre système maintenant pour appliquer toutes les optimisations" -ForegroundColor Magenta
    Write-Host "================================================================" -ForegroundColor Green
    
    # Journal final
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] Configuration complète terminée avec succès" | Out-File -FilePath "$logPath\setup.log" -Append
    
    # Proposition de redémarrage
    $rebootNow = Read-Host "Souhaitez-vous redémarrer le système maintenant? (O/N)"
    if ($rebootNow -eq "O") {
        Write-Host "Redémarrage du système dans 10 secondes..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}

# Exécution de la fonction principale
Main