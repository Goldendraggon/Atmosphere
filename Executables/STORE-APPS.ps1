param(
    [switch]$Files,
    [switch]$Notepads,
    [switch]$AppFetch,
    [switch]$UniGetUI,
    [switch]$FluentTerminal
)

.\AtmosphereModules\initPowerShell.ps1

function Remove-TempDirectory { Pop-Location; Remove-Item -Path $tempDir -Force -Recurse -EA 0 }
$tempDir = Join-Path -Path $(Get-SystemDrive) -ChildPath $([System.Guid]::NewGuid())
New-Item $tempDir -ItemType Directory -Force | Out-Null
Push-Location $tempDir

if ($Files) {
    Write-Output "Downloading Files..."
    $packagePath = Join-Path $tempDir "Files.Package_3.9.1.0_x64_arm64.msixbundle"
    & curl.exe -L "https://cdn.files.community/files/stable/Files.Package_3.9.1.0_Test/Files.Package_3.9.1.0_x64_arm64.msixbundle" -o $packagePath
    Add-AppxPackage -Path $packagePath
    Write-Output "Files installed."
    Remove-TempDirectory
}

if ($Notepads) {
    Write-Output "Downloading Notepads..."
    $githubApi = Invoke-RestMethod "https://api.github.com/repos/0x7c13/Notepads/releases/latest" -EA 0
    $packageUrl = $githubApi.assets.browser_download_url | Where-Object { $_ -like "*.msixbundle" } | Select-Object -First 1
    $packagePath = Join-Path $tempDir "Notepads_x86_x64_arm64.msixbundle"
    & curl.exe -L $packageUrl -o $packagePath
    Add-AppxPackage -Path $packagePath
    Write-Host "Notepads installed."
    Remove-TempDirectory
}

if ($AppFetch) {
    # MS Store App Fetcher 
    # https://github.com/Ameliorated-LLC/appfetch
    # Experimental and has known compatibility issues with some apps.
    $build = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild

    if ($build -ge 22000) {
        Write-Output "Downloading MS Store App Fetcher..."
        $DesktopPath = [Environment]::GetFolderPath("Desktop")
        $githubApi = Invoke-RestMethod "https://api.github.com/repos/Ameliorated-LLC/appfetch/releases/latest" -EA 0
        $exeUrl = $githubApi.assets.browser_download_url | Where-Object { $_ -like "*.exe" } | Select-Object -First 1
        $exePath = Join-Path $tempDir "App Fetch.exe"
        & curl.exe -L $exeUrl -o $exePath
        Move-Item -Path "$exePath" -Destination "$DesktopPath\App Fetch.exe" -Force
        Write-Output "MS Store App Fetcher downloaded to your Desktop."
        Remove-TempDirectory
    }
    else {
        Write-Output "MS Store App Fetcher UI gets broken in Windows 10"
        Remove-TempDirectory
        return
    }
}

if ($UniGetUI) {
    Write-Output "Downloading UniGetUI..."
    $githubApi = Invoke-RestMethod "https://api.github.com/repos/marticliment/UniGetUI/releases/latest" -EA 0
    $exeUrl = $githubApi.assets.browser_download_url | Where-Object { $_ -like "*.exe" } | Select-Object -First 1
    $exePath = Join-Path $tempDir "UniGetUI.Installer.exe"
    & curl.exe -L $exeUrl -o $exePath
    Start-Process -FilePath $exePath -ArgumentList  "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /NoAutoStart"
    Start-Sleep -Seconds 100
    Stop-Process -Name "UniGetUI.exe" -Force
    Remove-TempDirectory
    Write-Output "UniGetUI Installed."
}

if ($FluentTerminal) {
    Write-Output "Downloading Fluent Terminal..."
    $githubApi = Invoke-RestMethod "https://api.github.com/repos/felixse/FluentTerminal/releases/latest" -EA 0
    $zipUrl = $githubApi.assets.browser_download_url | Where-Object { $_ -like "*.zip" } | Select-Object -First 1
    $zipPath = Join-Path $tempDir "FluentTerminal.Package_0.7.7.0.zip"
    & curl.exe -L $zipUrl -o $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $tempDir
    Add-AppxPackage -Path "$tempDir\FluentTerminal.Package_0.7.7.0_x86_x64.msixbundle"
    Write-Output "Fluent Terminal Installed."
    Remove-TempDirectory
}