# Laptop_Full_Check.ps1
# V2: Quick report + optional extended tests for laptop checking at store.
# Khong cai them phan mem. Khong can Internet. Nen chay bang Run_Laptop_Test_Admin.bat.

$ErrorActionPreference = "SilentlyContinue"

function Add-Line {
    param([string]$Text = "")
    $script:Lines.Add($Text)
}
function Section {
    param([string]$Title)
    Add-Line ""
    Add-Line ("=" * 100)
    Add-Line $Title
    Add-Line ("=" * 100)
}
function ToText {
    param($Obj)
    if ($null -eq $Obj) { return "(khong doc duoc)" }
    return ($Obj | Out-String).TrimEnd()
}
function Save-Cmd {
    param([string]$Name, [string]$Command)
    $path = Join-Path $outDir $Name
    Add-Line "Dang chay: $Command"
    Add-Line "Output: $path"
    try {
        cmd /c $Command > $path 2>&1
    } catch {
        "FAILED: $_" | Out-File $path -Encoding utf8
    }
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outDir = $scriptDir

$script:Lines = New-Object System.Collections.Generic.List[string]
Add-Line "LAPTOP FULL TEST KIT V2 REPORT"
Add-Line "Thoi gian: $(Get-Date)"
Add-Line "May: $env:COMPUTERNAME"
Add-Line "User: $env:USERNAME"
Add-Line "Report folder: $outDir"
Add-Line ""
Add-Line "MUC TIEU: check nhanh cau hinh, serial, CPU, GPU, RAM, SSD, pin, driver, loi he thong."
Add-Line "LUU Y: GPU TGP, mau sac man hinh, loa, webcam, phim, cong USB van can test thu cong/HTML."

Section "1) THONG TIN MAY / SERIAL / BIOS"
$cs = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
$prod = Get-CimInstance Win32_ComputerSystemProduct
$bb = Get-CimInstance Win32_BaseBoard
Add-Line ("Hang/Model       : {0} {1}" -f $cs.Manufacturer, $cs.Model)
Add-Line ("System SKU       : {0}" -f $cs.SystemSKUNumber)
Add-Line ("Serial BIOS      : {0}" -f $bios.SerialNumber)
Add-Line ("UUID             : {0}" -f $prod.UUID)
Add-Line ("BIOS             : {0} - {1}" -f $bios.SMBIOSBIOSVersion, $bios.ReleaseDate)
Add-Line ("Mainboard        : {0} {1} | Serial: {2}" -f $bb.Manufacturer, $bb.Product, $bb.SerialNumber)
Add-Line ("RAM total        : {0:N2} GB" -f ($cs.TotalPhysicalMemory / 1GB))
Add-Line ("Domain/Workgroup : {0}" -f $cs.Domain)

Section "2) CPU"
$cpu = Get-CimInstance Win32_Processor
$cpu | ForEach-Object {
    Add-Line ("Name                 : {0}" -f $_.Name)
    Add-Line ("Manufacturer         : {0}" -f $_.Manufacturer)
    Add-Line ("Cores / Threads      : {0} / {1}" -f $_.NumberOfCores, $_.NumberOfLogicalProcessors)
    Add-Line ("Current/Max clock MHz: {0} / {1}" -f $_.CurrentClockSpeed, $_.MaxClockSpeed)
    Add-Line ("L2/L3 Cache KB       : {0} / {1}" -f $_.L2CacheSize, $_.L3CacheSize)
    Add-Line ("Socket               : {0}" -f $_.SocketDesignation)
    Add-Line ("Virtualization       : {0}" -f $_.VirtualizationFirmwareEnabled)
}

Section "3) GPU / MAN HINH"
$gpus = Get-CimInstance Win32_VideoController
foreach ($g in $gpus) {
    Add-Line ("GPU          : {0}" -f $g.Name)
    Add-Line ("VRAM approx  : {0:N2} GB" -f ($g.AdapterRAM / 1GB))
    Add-Line ("Driver       : {0} - {1}" -f $g.DriverVersion, $g.DriverDate)
    Add-Line ("Resolution   : {0} x {1}" -f $g.CurrentHorizontalResolution, $g.CurrentVerticalResolution)
    Add-Line ("Refresh rate : {0} Hz" -f $g.CurrentRefreshRate)
    Add-Line ("Video mode   : {0}" -f $g.VideoModeDescription)
    if ($g.Name -match "NVIDIA") {
        $smi = Get-Command "nvidia-smi" -ErrorAction SilentlyContinue
        if ($smi) {
            $tgpInfo = & "nvidia-smi" -q -d POWER | Select-String "Max Power Limit" | Select-Object -First 1
            if ($tgpInfo) {
                Add-Line ("NVIDIA TGP   : {0}" -f $tgpInfo.Line.Trim())
            }
        }
    }
    Add-Line ""
}
$monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID
if ($monitors) {
    Add-Line "Monitor EDID:"
    foreach ($m in $monitors) {
        $name = ($m.UserFriendlyName | Where-Object { $_ -ne 0 } | ForEach-Object {[char]$_}) -join ""
        $serial = ($m.SerialNumberID | Where-Object { $_ -ne 0 } | ForEach-Object {[char]$_}) -join ""
        Add-Line ("Monitor: {0} | Serial: {1} | Week/Year: {2}/{3}" -f $name, $serial, $m.WeekOfManufacture, $m.YearOfManufacture)
    }
} else {
    Add-Line "Khong doc duoc EDID monitor."
}

Section "4) RAM SLOT"
$mem = Get-CimInstance Win32_PhysicalMemory
if ($mem) {
    $i = 1
    foreach ($m in $mem) {
        Add-Line ("Slot {0}: {1:N0} GB | {2} MHz | Configured {3} MHz | {4} | Part: {5} | Serial: {6}" -f $i, ($m.Capacity/1GB), $m.Speed, $m.ConfiguredClockSpeed, $m.Manufacturer, $m.PartNumber, $m.SerialNumber)
        $i++
    }
} else {
    Add-Line "Khong doc duoc thong tin RAM."
}

Section "5) SSD / O CUNG / S.M.A.R.T"
$disks = Get-CimInstance Win32_DiskDrive
foreach ($d in $disks) {
    Add-Line ("Disk        : {0}" -f $d.Model)
    Add-Line ("Size        : {0:N2} GB" -f ($d.Size / 1GB))
    Add-Line ("Interface   : {0}" -f $d.InterfaceType)
    Add-Line ("Serial      : {0}" -f $d.SerialNumber)
    Add-Line ("Status      : {0}" -f $d.Status)
    Add-Line ("Partitions  : {0}" -f $d.Partitions)
    Add-Line ""
}
$physicalDisks = Get-PhysicalDisk
if ($physicalDisks) {
    Add-Line "Get-PhysicalDisk / StorageReliabilityCounter:"
    foreach ($pd in $physicalDisks) {
        Add-Line ("FriendlyName: {0} | MediaType: {1} | Health: {2} | Operational: {3} | Size: {4:N2} GB" -f $pd.FriendlyName, $pd.MediaType, $pd.HealthStatus, ($pd.OperationalStatus -join ","), ($pd.Size/1GB))
        $rel = $pd | Get-StorageReliabilityCounter
        if ($rel) {
            Add-Line ("  Wear: {0} | Temp: {1} C | ReadErrors: {2} | WriteErrors: {3} | PowerOnHours: {4}" -f $rel.Wear, $rel.Temperature, $rel.ReadErrorsTotal, $rel.WriteErrorsTotal, $rel.PowerOnHours)
        }
    }
}

Section "6) PHAN VUNG / DUNG LUONG"
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    Add-Line ("Drive {0} | Size {1:N2} GB | Free {2:N2} GB | FileSystem {3}" -f $_.DeviceID, ($_.Size/1GB), ($_.FreeSpace/1GB), $_.FileSystem)
}

Section "7) PIN / BATTERY"
$batt = Get-CimInstance Win32_Battery
if ($batt) {
    foreach ($b in $batt) {
        Add-Line ("Battery: {0}" -f $b.Name)
        Add-Line ("Status : {0}" -f $b.Status)
        Add-Line ("Charge : {0}%" -f $b.EstimatedChargeRemaining)
        Add-Line ("Runtime estimate: {0} minutes" -f $b.EstimatedRunTime)
    }
} else {
    Add-Line "Khong doc duoc Win32_Battery."
}
$battReport = Join-Path $outDir "battery_report_$timestamp.html"
powercfg /batteryreport /output "$battReport" | Out-Null
Add-Line "Battery report da tao: $battReport"
Add-Line "Trong battery-report.html hay xem: DESIGN CAPACITY, FULL CHARGE CAPACITY, CYCLE COUNT."

Section "8) WIFI / BLUETOOTH / NETWORK"
Add-Line "Network adapters:"
Get-NetAdapter | Sort-Object Name | ForEach-Object {
    Add-Line ("{0} | Status: {1} | Link: {2} | MAC: {3}" -f $_.Name, $_.Status, $_.LinkSpeed, $_.MacAddress)
}
Add-Line ""
Add-Line "Wi-Fi driver:"
(netsh wlan show drivers | Out-String) | ForEach-Object { Add-Line $_ }
Add-Line ""
Add-Line "Bluetooth devices:"
Get-PnpDevice -Class Bluetooth | Select-Object Status, Class, FriendlyName, InstanceId | Format-Table -AutoSize | Out-String | ForEach-Object { Add-Line $_ }

Section "9) AUDIO / CAMERA / USB DEVICE"
Add-Line "Audio devices:"
Get-PnpDevice -Class AudioEndpoint | Select-Object Status, FriendlyName, InstanceId | Format-Table -AutoSize | Out-String | ForEach-Object { Add-Line $_ }
Add-Line ""
Add-Line "Camera/Image devices:"
Get-PnpDevice -Class Camera,Image | Select-Object Status, Class, FriendlyName, InstanceId | Format-Table -AutoSize | Out-String | ForEach-Object { Add-Line $_ }
Add-Line ""
Add-Line "USB controllers/devices:"
Get-PnpDevice -Class USB | Select-Object Status, FriendlyName, InstanceId | Format-Table -AutoSize | Out-String | ForEach-Object { Add-Line $_ }

Section "10) DEVICE MANAGER - LOI DRIVER"
$badDevices = Get-CimInstance Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 }
if ($badDevices) {
    Add-Line "CANH BAO: Co thiet bi dang loi driver/device:"
    $badDevices | Select-Object Name, Manufacturer, DeviceID, ConfigManagerErrorCode | Format-Table -AutoSize | Out-String | ForEach-Object { Add-Line $_ }
} else {
    Add-Line "OK: Khong thay thiet bi loi trong Device Manager."
}

Section "11) WINDOWS / LICENSE / TPM / SECURE BOOT"
$os = Get-CimInstance Win32_OperatingSystem
Add-Line ("Windows     : {0}" -f $os.Caption)
Add-Line ("Version     : {0} | Build: {1}" -f $os.Version, $os.BuildNumber)
Add-Line ("Install date: {0}" -f $os.InstallDate)
$lic = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -and $_.LicenseStatus -eq 1 } | Select-Object -First 5 Name, Description, PartialProductKey, LicenseStatus
Add-Line "Activated licenses:"
Add-Line (ToText $lic)
$tpm = Get-Tpm
if ($tpm) {
    Add-Line ("TPM Present: {0} | Ready: {1} | Enabled: {2}" -f $tpm.TpmPresent, $tpm.TpmReady, $tpm.TpmEnabled)
}
try {
    Add-Line ("Secure Boot: {0}" -f (Confirm-SecureBootUEFI))
} catch {
    Add-Line "Secure Boot: khong doc duoc / may dang Legacy / khong phai UEFI."
}

Section "12) NHIET DO CO BAN"
$temps = Get-CimInstance -Namespace root/wmi -Class MSAcpi_ThermalZoneTemperature
if ($temps) {
    foreach ($t in $temps) {
        $c = ($t.CurrentTemperature / 10) - 273.15
        Add-Line ("ThermalZone {0}: {1:N1} C" -f $t.InstanceName, $c)
    }
} else {
    Add-Line "Windows khong expose nhiet do CPU/GPU qua WMI. Nen xem them trong BIOS/HWInfo/HWMonitor neu shop cho phep."
}

Section "13) EVENT LOG - LOI GAN DAY"
Add-Line "System errors/warnings 24h gan day, toi da 40 dong:"
$events = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddHours(-24); Level=1,2,3} -MaxEvents 40
if ($events) {
    $events | Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message | Format-List | Out-String | ForEach-Object { Add-Line $_ }
} else {
    Add-Line "Khong thay error/warning nghiem trong trong 24h gan day."
}

Section "14) DXDIAG"
$dxPath = Join-Path $outDir "dxdiag_$timestamp.txt"
Start-Process -FilePath "dxdiag.exe" -ArgumentList "/dontskip /whql:off /t `"$dxPath`"" -Wait
Add-Line "DxDiag da tao: $dxPath"

# Save early before optional tests
$reportTxt = Join-Path $outDir "Laptop_Full_Check_Report_$timestamp.txt"
$Lines | Out-File -FilePath $reportTxt -Encoding utf8

Write-Host ""
Write-Host "Quick Check da xong." -ForegroundColor Green
Write-Host "Report folder: $outDir" -ForegroundColor Green
Write-Host ""
Write-Host "Extended Test gom: disk benchmark nhe, winsat CPU/RAM/Disk/D3D neu Windows ho tro." -ForegroundColor Yellow
Write-Host "Chi nen chay neu shop cho test 5-10 phut va may dang cam sac." -ForegroundColor Yellow
$ans = Read-Host "Ban co muon chay Extended Test khong? (y/N)"

if ($ans -match '^(y|Y|yes|YES)$') {
    Section "15) EXTENDED TEST - DISK BENCHMARK NHE"
    try {
        $testFile = Join-Path $outDir "disk_test_512MB.tmp"
        $sizeMB = 512
        $buffer = New-Object byte[] (4MB)
        (New-Object Random).NextBytes($buffer)
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $fs = [IO.File]::Open($testFile, [IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::None)
        for ($i=0; $i -lt ($sizeMB/4); $i++) { $fs.Write($buffer, 0, $buffer.Length) }
        $fs.Close()
        $sw.Stop()
        $writeMBs = $sizeMB / $sw.Elapsed.TotalSeconds
        Add-Line ("Write test: {0} MB in {1:N2}s = {2:N2} MB/s" -f $sizeMB, $sw.Elapsed.TotalSeconds, $writeMBs)

        $readBuffer = New-Object byte[] (4MB)
        $sw.Restart()
        $fs = [IO.File]::Open($testFile, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        while (($n = $fs.Read($readBuffer, 0, $readBuffer.Length)) -gt 0) { }
        $fs.Close()
        $sw.Stop()
        $readMBs = $sizeMB / $sw.Elapsed.TotalSeconds
        Add-Line ("Read test : {0} MB in {1:N2}s = {2:N2} MB/s" -f $sizeMB, $sw.Elapsed.TotalSeconds, $readMBs)
        Remove-Item $testFile -Force
    } catch {
        Add-Line "Disk benchmark bi loi: $_"
    }

    Section "16) EXTENDED TEST - WINSAT"
    Add-Line "WinSAT la cong cu co san cua Windows. Neu bi loi thi bo qua, khong phai loi may."
    Save-Cmd "winsat_cpu.txt" "winsat cpuformal"
    Save-Cmd "winsat_mem.txt" "winsat mem"
    Save-Cmd "winsat_disk_c.txt" "winsat disk -drive C"
    Save-Cmd "winsat_d3d.txt" "winsat d3d"

    Section "17) EXTENDED TEST - CPU LOAD NGAN"
    Add-Line "CPU load ngan 60 giay bang RunspacePool. Muc dich: xem may co crash/treo bat thuong khong."
    try {
        $logical = [Environment]::ProcessorCount
        $pool = [runspacefactory]::CreateRunspacePool(1, $logical)
        $pool.Open()
        $jobs = @()
        $endTime = (Get-Date).AddSeconds(60)
        for ($i=0; $i -lt $logical; $i++) {
            $ps = [powershell]::Create().AddScript({
                param($endTicks)
                while ((Get-Date).Ticks -lt $endTicks) {
                    $x = 0.0001
                    for ($j=0; $j -lt 20000; $j++) { $x = [Math]::Sqrt($x + 1.2345) }
                }
            }).AddArgument($endTime.Ticks)
            $ps.RunspacePool = $pool
            $jobs += [PSCustomObject]@{ Pipe = $ps; Status = $ps.BeginInvoke() }
        }
        while ((Get-Date) -lt $endTime) {
            Start-Sleep -Seconds 5
            Write-Host "." -NoNewline
        }
        foreach ($j in $jobs) { $j.Pipe.EndInvoke($j.Status) | Out-Null; $j.Pipe.Dispose() }
        $pool.Close()
        $pool.Dispose()
        Add-Line "CPU load 60s: DONE. Neu may khong treo/khong tat dot ngot la dat test co ban."
    } catch {
        Add-Line "CPU load test bi loi: $_"
    }

    $Lines | Out-File -FilePath $reportTxt -Encoding utf8
}

Start-Process notepad.exe $reportTxt
if (Test-Path $battReport) { Start-Process $battReport }
Start-Process (Join-Path $scriptDir "Screen_Color_Test.html")
Start-Process (Join-Path $scriptDir "Keyboard_Test.html")
Start-Process (Join-Path $scriptDir "Audio_Webcam_Mic_Test.html")

Write-Host ""
Write-Host "DONE. Cac file bao cao nam tai thu muc hien tai:" $outDir -ForegroundColor Green
Write-Host "Da mo report, battery report va 3 trang test HTML." -ForegroundColor Green
Write-Host "Nho test thu cong them: cong USB/Type-C/HDMI, sac, ban le, loa, webcam, phim, touchpad, dead pixel." -ForegroundColor Yellow
