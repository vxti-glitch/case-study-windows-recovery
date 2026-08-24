[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [string]$OutputPath = ".\reports\windows-recovery-baseline.json",

    [Parameter()]
    [switch]$IncludeSystemFileScan
)

Set-StrictMode -Version Latest

function Get-ServiceSnapshot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Name
    )

    $snapshot = foreach ($serviceName in $Name) {
        try {
            $service = Get-Service -Name $serviceName -ErrorAction Stop
            $serviceConfig = Get-CimInstance -ClassName Win32_Service -Filter "Name='$serviceName'" -ErrorAction Stop
            [ordered]@{
                name = $serviceName
                status = $service.Status.ToString()
                start_mode = $serviceConfig.StartMode
            }
        }
        catch {
            [ordered]@{
                name = $serviceName
                status = "unavailable"
                start_mode = ""
                error = $_.Exception.Message
            }
        }
    }

    return @($snapshot)
}

function Get-RegistrySnapshot {
    [CmdletBinding()]
    param()

    $targets = @(
        @{
            path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
            values = @("EnableLUA", "ConsentPromptBehaviorAdmin", "PromptOnSecureDesktop")
        }
    )

    $snapshot = foreach ($target in $targets) {
        $values = [ordered]@{}
        foreach ($valueName in $target.values) {
            try {
                $values[$valueName] = Get-ItemPropertyValue -LiteralPath $target.path -Name $valueName -ErrorAction Stop
            }
            catch {
                $values[$valueName] = $null
            }
        }

        [ordered]@{
            path = $target.path
            values = $values
        }
    }

    return @($snapshot)
}

function Get-RecoveryPointSnapshot {
    [CmdletBinding()]
    param()

    try {
        $points = @(Get-ComputerRestorePoint -ErrorAction Stop | Sort-Object -Property CreationTime -Descending)
        return [ordered]@{
            available = $true
            count = $points.Count
            newest = if ($points.Count) { $points[0].CreationTime.ToString("o") } else { "" }
        }
    }
    catch {
        return [ordered]@{
            available = $false
            count = 0
            newest = ""
            error = $_.Exception.Message
        }
    }
}

function Invoke-SystemFileVerification {
    [CmdletBinding()]
    param()

    try {
        $output = & sfc.exe /verifyonly 2>&1 | ForEach-Object { $_.ToString() }
        return [ordered]@{
            command = "sfc /verifyonly"
            exit_code = $LASTEXITCODE
            output = @($output)
        }
    }
    catch {
        return [ordered]@{
            command = "sfc /verifyonly"
            exit_code = -1
            output = @()
            error = $_.Exception.Message
        }
    }
}

function Get-WindowsRecoveryBaseline {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$RunSystemFileVerification
    )

    if ($env:OS -ne "Windows_NT") {
        throw "This collector must run on Windows."
    }

    $operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop

    $payload = [ordered]@{
        collected_at = (Get-Date).ToUniversalTime().ToString("o")
        computer = [ordered]@{
            name = $env:COMPUTERNAME
            manufacturer = $computerSystem.Manufacturer
            model = $computerSystem.Model
        }
        operating_system = [ordered]@{
            caption = $operatingSystem.Caption
            version = $operatingSystem.Version
            build_number = $operatingSystem.BuildNumber
            last_boot_time = $operatingSystem.LastBootUpTime.ToUniversalTime().ToString("o")
        }
        recovery_points = Get-RecoveryPointSnapshot
        services = Get-ServiceSnapshot -Name @("EventLog", "Schedule", "Winmgmt", "wuauserv", "BITS", "SecurityHealthService")
        registry_policy_snapshot = Get-RegistrySnapshot
        system_file_verification = $null
        collection_notes = @(
            "The collector is read-only except for writing the requested report file.",
            "Registry values are captured for comparison; the tool does not determine whether a value is correct for a specific environment.",
            "Review findings against approved organizational baselines and Microsoft documentation before changing a system."
        )
    }

    if ($RunSystemFileVerification) {
        $payload.system_file_verification = Invoke-SystemFileVerification
    }

    return $payload
}

function Save-RecoveryBaseline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Baseline,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $directory = Split-Path -Parent $fullPath
    [System.IO.Directory]::CreateDirectory($directory) | Out-Null
    $json = $Baseline | ConvertTo-Json -Depth 8
    [System.IO.File]::WriteAllText($fullPath, $json, [System.Text.UTF8Encoding]::new($false))
    return $fullPath
}

if ($MyInvocation.InvocationName -ne ".") {
    $baseline = Get-WindowsRecoveryBaseline -RunSystemFileVerification:$IncludeSystemFileScan
    if ($PSCmdlet.ShouldProcess($OutputPath, "write Windows recovery baseline report")) {
        $writtenPath = Save-RecoveryBaseline -Baseline $baseline -Path $OutputPath
        Write-Host "Baseline written to $writtenPath"
    }
}
