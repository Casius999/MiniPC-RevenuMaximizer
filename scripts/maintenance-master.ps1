# Script de Maintenance Master pour Mini PCs
# Auteur: Casius999
# Version: 1.0
# Ce script effectue une maintenance complète et génère un rapport détaillé

# Variables de configuration
$installPath = "$env:USERPROFILE\MiniPC-RevenuMaximizer"
$logPath = "$installPath\logs"
$configPath = "$installPath\config"
$reportPath = "$installPath\reports"
$applications = @("honeygain", "IPRoyal Pawns", "Peer2Profit", "packetstream", "traffmonetizer")
$logFile = "$logPath\maintenance_master_$(Get-Date -Format 'yyyy-MM-dd').log"
$reportFile = "$reportPath\health_report_$(Get-Date -Format 'yyyy-MM-dd').html"

# Création des dossiers nécessaires
function Initialize-Environment {
    if (!(Test-Path $reportPath)) {
        New-Item -ItemType Directory -Path $reportPath -Force | Out-Null
    }
}

# Fonction de logging
function Log-Message {
    param([string]$message, [string]$type = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp [$type] - $message" | Out-File -FilePath $logFile -Append
    
    switch ($type) {
        "INFO" { Write-Host "$timestamp - $message" -ForegroundColor White }
        "SUCCESS" { Write-Host "$timestamp - $message" -ForegroundColor Green }
        "WARNING" { Write-Host "$timestamp - $message" -ForegroundColor Yellow }
        "ERROR" { Write-Host "$timestamp - $message" -ForegroundColor Red }
        default { Write-Host "$timestamp - $message" }
    }
}

# Vérification et redémarrage des applications
function Check-Applications {
    Log-Message "Vérification des applications..." "INFO"
    $results = @()
    
    foreach ($app in $applications) {
        $process = Get-Process -Name $app -ErrorAction SilentlyContinue
        if ($null -eq $process) {
            Log-Message "Application $app non exécutée. Redémarrage..." "WARNING"
            
            switch ($app) {
                "honeygain" { 
                    Start-Process "C:\Program Files\Honeygain\honeygain.exe" 
                    $path = "C:\Program Files\Honeygain\honeygain.exe"
                }
                "IPRoyal Pawns" { 
                    Start-Process "C:\Program Files\IPRoyal Pawns\IPRoyal Pawns.exe" 
                    $path = "C:\Program Files\IPRoyal Pawns\IPRoyal Pawns.exe"
                }
                "Peer2Profit" { 
                    Start-Process "C:\Program Files\Peer2Profit\Peer2Profit.exe" 
                    $path = "C:\Program Files\Peer2Profit\Peer2Profit.exe"
                }
                "packetstream" { 
                    Start-Process "C:\Program Files\PacketStream\packetstream.exe" 
                    $path = "C:\Program Files\PacketStream\packetstream.exe"
                }
                "traffmonetizer" { 
                    Start-Process "C:\Program Files\TraffMonetizer\traffmonetizer.exe" 
                    $path = "C:\Program Files\TraffMonetizer\traffmonetizer.exe"
                }
            }
            
            Start-Sleep -Seconds 5
            $process = Get-Process -Name $app -ErrorAction SilentlyContinue
            
            if ($null -eq $process) {
                $status = "Échec de redémarrage"
                $statusColor = "Red"
                Log-Message "Échec du redémarrage de $app" "ERROR"
            } else {
                $status = "Redémarré avec succès"
                $statusColor = "Orange"
                Log-Message "$app redémarré avec succès" "SUCCESS"
            }
        } else {
            $status = "En cours d'exécution"
            $statusColor = "Green"
            Log-Message "$app en cours d'exécution: OK" "SUCCESS"
        }
        
        $appInfo = [PSCustomObject]@{
            Name = $app
            Status = $status
            StatusColor = $statusColor
            Memory = if ($process) { [math]::Round($process.WorkingSet / 1MB, 2) } else { "N/A" }
            CPU = if ($process) { [math]::Round($process.CPU, 2) } else { "N/A" }
            Uptime = if ($process) { (Get-Date) - $process.StartTime } else { "N/A" }
        }
        
        $results += $appInfo
    }
    
    return $results
}

# Nettoyage système
function Clean-System {
    Log-Message "Nettoyage du système..." "INFO"
    
    # Fichiers temporaires Windows
    Log-Message "Nettoyage des fichiers temporaires..." "INFO"
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
    
    # Corbeille
    Log-Message "Vidage de la corbeille..." "INFO"
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    
    # Cache DNS
    Log-Message "Purge du cache DNS..." "INFO"
    Clear-DnsClientCache
    
    # Optimisation mémoire
    Log-Message "Optimisation de la mémoire..." "INFO"
    [System.GC]::Collect()
    
    Log-Message "Nettoyage système terminé" "SUCCESS"
}

# Vérification santé du système
function Check-SystemHealth {
    Log-Message "Vérification de la santé du système..." "INFO"
    
    # Informations système
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cpu = Get-CimInstance -ClassName Win32_Processor
    $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
    
    # Calculs
    $uptime = (Get-Date) - $os.LastBootUpTime
    $totalMemory = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeMemory = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedMemory = $totalMemory - $freeMemory
    $memoryPercent = [math]::Round(($usedMemory / $totalMemory) * 100, 0)
    
    $totalDisk = [math]::Round($disk.Size / 1GB, 2)
    $freeDisk = [math]::Round($disk.FreeSpace / 1GB, 2)
    $usedDisk = $totalDisk - $freeDisk
    $diskPercent = [math]::Round(($usedDisk / $totalDisk) * 100, 0)
    
    # Utilisation CPU actuelle
    $cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $cpuPercent = [math]::Round($cpuUsage, 0)
    
    # Température CPU (si disponible)
    $tempAvailable = $false
    $cpuTemp = "N/A"
    
    try {
        $temp = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -ErrorAction SilentlyContinue
        if ($temp) {
            $cpuTemp = [math]::Round(($temp.CurrentTemperature / 10) - 273.15, 1)
            $tempAvailable = $true
        }
    } catch {
        $tempAvailable = $false
    }
    
    # Résultat
    $healthResult = [PSCustomObject]@{
        OSVersion = $os.Caption
        LastBoot = $os.LastBootUpTime
        Uptime = "$($uptime.Days) jours, $($uptime.Hours) heures, $($uptime.Minutes) minutes"
        CPUModel = $cpu.Name
        CPUUsage = "$cpuPercent%"
        CPUTemp = $cpuTemp
        TempAvailable = $tempAvailable
        TotalMemory = "$totalMemory GB"
        UsedMemory = "$usedMemory GB"
        MemoryPercent = $memoryPercent
        TotalDisk = "$totalDisk GB"
        UsedDisk = "$usedDisk GB"
        DiskPercent = $diskPercent
    }
    
    Log-Message "Vérification santé système terminée" "SUCCESS"
    return $healthResult
}

# Vérification réseau
function Check-Network {
    Log-Message "Vérification de la connectivité réseau..." "INFO"
    
    $pingTargets = @{
        "Google" = "8.8.8.8"
        "Cloudflare" = "1.1.1.1"
        "Honeygain" = "dashboard.honeygain.com"
        "IPRoyal" = "iproyal.com"
    }
    
    $results = @()
    
    foreach ($target in $pingTargets.GetEnumerator()) {
        $pingResult = Test-Connection -ComputerName $target.Value -Count 2 -Quiet
        if ($pingResult) {
            $status = "Connecté"
            $statusColor = "Green"
            Log-Message "Connectivité vers $($target.Key) ($($target.Value)): OK" "SUCCESS"
        } else {
            $status = "Non connecté"
            $statusColor = "Red"
            Log-Message "Connectivité vers $($target.Key) ($($target.Value)): ÉCHEC" "ERROR"
        }
        
        $networkInfo = [PSCustomObject]@{
            Target = $target.Key
            Address = $target.Value
            Status = $status
            StatusColor = $statusColor
        }
        
        $results += $networkInfo
    }
    
    # Informations adaptateur réseau
    $networkAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Loopback*" } | Select-Object -First 1
    if ($networkAdapter) {
        $adapterInfo = Get-NetAdapterAdvancedProperty -Name $networkAdapter.Name
        $ipInfo = Get-NetIPAddress -InterfaceIndex $networkAdapter.ifIndex -AddressFamily IPv4
        
        $adapterData = [PSCustomObject]@{
            Name = $networkAdapter.Name
            Type = $networkAdapter.InterfaceDescription
            Speed = "$([math]::Round($networkAdapter.LinkSpeed / 1000000, 0)) Mbps"
            IPAddress = $ipInfo.IPAddress
            Status = $networkAdapter.Status
        }
    } else {
        $adapterData = [PSCustomObject]@{
            Name = "Aucun adaptateur actif trouvé"
            Type = "N/A"
            Speed = "N/A"
            IPAddress = "N/A"
            Status = "N/A"
        }
    }
    
    Log-Message "Vérification réseau terminée" "SUCCESS"
    return @{
        PingResults = $results
        NetworkAdapter = $adapterData
    }
}

# Génération rapport HTML
function Generate-HTMLReport {
    param(
        [array]$appResults,
        [PSCustomObject]$healthResult,
        [hashtable]$networkResults
    )
    
    Log-Message "Génération du rapport HTML..." "INFO"
    
    $reportDate = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    $computerName = $env:COMPUTERNAME
    
    $html = @"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport Santé MiniPC - $reportDate</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            border-radius: 5px;
        }
        h1 {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #2c3e50;
            margin-top: 30px;
            border-bottom: 1px solid #ddd;
            padding-bottom: 5px;
        }
        .header-info {
            display: flex;
            justify-content: space-between;
            background-color: #f9f9f9;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .header-info div {
            flex: 1;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ddd;
            text-align: left;
        }
        th {
            background-color: #3498db;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .status-green {
            color: green;
            font-weight: bold;
        }
        .status-red {
            color: red;
            font-weight: bold;
        }
        .status-orange {
            color: orange;
            font-weight: bold;
        }
        .meter {
            height: 20px;
            position: relative;
            background: #f3f3f3;
            border-radius: 25px;
            padding: 5px;
            box-shadow: inset 0 -1px 1px rgba(255,255,255,0.3);
        }
        .meter > span {
            display: block;
            height: 100%;
            border-radius: 20px;
            background-color: rgb(43,194,83);
            position: relative;
            overflow: hidden;
        }
        .critical > span {
            background-color: rgb(224,79,79);
        }
        .warning > span {
            background-color: rgb(255,165,0);
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            font-size: 0.8em;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Rapport de Santé MiniPC-RevenuMaximizer</h1>
        
        <div class="header-info">
            <div>
                <strong>Ordinateur:</strong> $computerName<br>
                <strong>Date du rapport:</strong> $reportDate<br>
                <strong>Système:</strong> $($healthResult.OSVersion)
            </div>
            <div>
                <strong>Uptime:</strong> $($healthResult.Uptime)<br>
                <strong>CPU:</strong> $($healthResult.CPUModel)<br>
                <strong>Mémoire:</strong> $($healthResult.TotalMemory)
            </div>
        </div>
        
        <h2>État des Applications</h2>
        <table>
            <thead>
                <tr>
                    <th>Application</th>
                    <th>Statut</th>
                    <th>Mémoire (MB)</th>
                    <th>CPU (%)</th>
                    <th>Temps Exécution</th>
                </tr>
            </thead>
            <tbody>
"@

    foreach ($app in $appResults) {
        $uptimeDisplay = if ($app.Uptime -eq "N/A") { "N/A" } else { "$($app.Uptime.Days)j $($app.Uptime.Hours)h $($app.Uptime.Minutes)m" }
        
        $html += @"
                <tr>
                    <td>$($app.Name)</td>
                    <td class="status-$($app.StatusColor.ToLower())">$($app.Status)</td>
                    <td>$($app.Memory)</td>
                    <td>$($app.CPU)</td>
                    <td>$uptimeDisplay</td>
                </tr>
"@
    }

    $html += @"
            </tbody>
        </table>
        
        <h2>Santé du Système</h2>
        <table>
            <tr>
                <td width="200"><strong>CPU Utilisation</strong></td>
                <td>
                    <div class="meter $(if($healthResult.CPUUsage.TrimEnd('%') -gt 90){'critical'}elseif($healthResult.CPUUsage.TrimEnd('%') -gt 70){'warning'})">
                        <span style="width: $($healthResult.CPUUsage)"></span>
                    </div>
                    $($healthResult.CPUUsage)
                </td>
            </tr>
"@

    if ($healthResult.TempAvailable) {
        $html += @"
            <tr>
                <td><strong>CPU Température</strong></td>
                <td>
                    <div class="meter $(if($healthResult.CPUTemp -gt 80){'critical'}elseif($healthResult.CPUTemp -gt 70){'warning'})">
                        <span style="width: $([math]::Min(100, $healthResult.CPUTemp))%"></span>
                    </div>
                    $($healthResult.CPUTemp)°C
                </td>
            </tr>
"@
    }

    $html += @"
            <tr>
                <td><strong>Mémoire Utilisation</strong></td>
                <td>
                    <div class="meter $(if($healthResult.MemoryPercent -gt 90){'critical'}elseif($healthResult.MemoryPercent -gt 70){'warning'})">
                        <span style="width: $($healthResult.MemoryPercent)%"></span>
                    </div>
                    $($healthResult.UsedMemory) / $($healthResult.TotalMemory) ($($healthResult.MemoryPercent)%)
                </td>
            </tr>
            <tr>
                <td><strong>Disque Utilisation</strong></td>
                <td>
                    <div class="meter $(if($healthResult.DiskPercent -gt 90){'critical'}elseif($healthResult.DiskPercent -gt 70){'warning'})">
                        <span style="width: $($healthResult.DiskPercent)%"></span>
                    </div>
                    $($healthResult.UsedDisk) / $($healthResult.TotalDisk) ($($healthResult.DiskPercent)%)
                </td>
            </tr>
            <tr>
                <td><strong>Dernier Démarrage</strong></td>
                <td>$($healthResult.LastBoot)</td>
            </tr>
        </table>
        
        <h2>Connectivité Réseau</h2>
        <h3>Adaptateur Réseau</h3>
        <table>
            <tr>
                <td width="200"><strong>Nom</strong></td>
                <td>$($networkResults.NetworkAdapter.Name)</td>
            </tr>
            <tr>
                <td><strong>Type</strong></td>
                <td>$($networkResults.NetworkAdapter.Type)</td>
            </tr>
            <tr>
                <td><strong>Adresse IP</strong></td>
                <td>$($networkResults.NetworkAdapter.IPAddress)</td>
            </tr>
            <tr>
                <td><strong>Vitesse</strong></td>
                <td>$($networkResults.NetworkAdapter.Speed)</td>
            </tr>
            <tr>
                <td><strong>Statut</strong></td>
                <td>$($networkResults.NetworkAdapter.Status)</td>
            </tr>
        </table>
        
        <h3>Tests de Connectivité</h3>
        <table>
            <thead>
                <tr>
                    <th>Destination</th>
                    <th>Adresse</th>
                    <th>Statut</th>
                </tr>
            </thead>
            <tbody>
"@

    foreach ($ping in $networkResults.PingResults) {
        $html += @"
                <tr>
                    <td>$($ping.Target)</td>
                    <td>$($ping.Address)</td>
                    <td class="status-$($ping.StatusColor.ToLower())">$($ping.Status)</td>
                </tr>
"@
    }

    $html += @"
            </tbody>
        </table>
        
        <div class="footer">
            <p>Rapport généré par MiniPC-RevenuMaximizer - Auteur: Casius999</p>
            <p>Date: $reportDate</p>
        </div>
    </div>
</body>
</html>
"@

    Set-Content -Path $reportFile -Value $html
    Log-Message "Rapport HTML généré: $reportFile" "SUCCESS"
    
    return $reportFile
}

# Fonction principale
function Main {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "=== MiniPC-RevenuMaximizer - Maintenance Master               ===" -ForegroundColor Cyan
    Write-Host "=== Auteur: Casius999                                        ===" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Temps de début pour calcul durée
    $startTime = Get-Date
    
    # Initialisation
    Initialize-Environment
    Log-Message "Début de la maintenance principale" "INFO"
    
    # Exécution des vérifications
    $appResults = Check-Applications
    $healthResult = Check-SystemHealth
    $networkResults = Check-Network
    
    # Nettoyage système
    Clean-System
    
    # Génération rapport
    $reportFile = Generate-HTMLReport -appResults $appResults -healthResult $healthResult -networkResults $networkResults
    
    # Calcul temps d'exécution
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    # Rapport final
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "=== Maintenance terminée avec succès!                        ===" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Temps d'exécution: $($duration.Minutes) minutes et $($duration.Seconds) secondes" -ForegroundColor White
    Write-Host ""
    Write-Host "Rapport de santé généré: $reportFile" -ForegroundColor Cyan
    Write-Host ""
    
    # Ouverture du rapport
    $openReport = Read-Host "Souhaitez-vous ouvrir le rapport maintenant? (O/N)"
    if ($openReport -eq "O") {
        Start-Process $reportFile
    }
    
    Log-Message "Maintenance principale terminée avec succès" "SUCCESS"
}

# Exécution de la fonction principale
Main