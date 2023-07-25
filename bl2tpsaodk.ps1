function Get-DirectoryPath {
    param (
        [string]$promptMessage = "Enter '2' for Borderlands 2, 'TPS' for Borderlands: The Pre-Sequel, 'AODK' for Assault on Dragon's Keep:",
        [string]$defaultPathBL2 = "C:\Program Files (x86)\Steam\steamapps\common\Borderlands 2",
        [string]$defaultPathTPS = "C:\Program Files (x86)\Steam\steamapps\common\BorderlandsPreSequel",
        [string]$defaultPathAODK = "C:\Program Files (x86)\Steam\steamapps\common\Pawpaw"
    )

    $defaultPaths = @{
        '2'     = $defaultPathBL2
        'TPS'   = $defaultPathTPS
        'AODK'  = $defaultPathAODK
    }

    do {
        $userChoice = Read-Host -Prompt $promptMessage
    } while (-not ($defaultPaths.ContainsKey($userChoice)))

    $selectedPath = Read-Host "Enter the path to your $($userChoice) folder and press Enter or press Enter for the default steam install dir"

    if ([string]::IsNullOrEmpty($selectedPath)) {
        $selectedPath = $defaultPaths[$userChoice]
    }

    while (-not (Test-Path -Path $selectedPath -PathType Container)) {
        Write-Host "The directory does not exist. Please try again."
        $selectedPath = Read-Host "Enter the path to your $($userChoice) folder and press Enter or press Enter for the default steam install dir"

        if ([string]::IsNullOrEmpty($selectedPath)) {
            $selectedPath = $defaultPaths[$userChoice]
        }
    }

    return Join-Path -Path $selectedPath -ChildPath "Binaries"
}

# Call the function to get the directory path from the user and add "/Binaries" to the path
$selectedPath = Get-DirectoryPath

# Download and extract pythonsdk
$pythonsdkUri = "https://github.com/SirGamers/bl2automod/raw/main/a.zip"
$pythonsdkZip = Join-Path -Path $selectedPath -ChildPath "a.zip"

try {
    Invoke-WebRequest -Uri $pythonsdkUri -OutFile $pythonsdkZip
    Expand-Archive -Path $pythonsdkZip -DestinationPath (Join-Path -Path $selectedPath -ChildPath "Win32") -Force
    Write-Host "Downloaded and extracted pythonsdk"
} catch {
    Write-Host "Failed to download or extract pythonsdk. Please check your internet connection and try again."
}

Remove-Item -Path $pythonsdkZip -Force
Write-Host "Removed file: $pythonsdkZip"

# Define the list of mods to download and extract
$mods = @(
    @{
        Name = "TextModLoader"
        Uri = "https://github.com/apple1417/bl-sdk-mods/raw/master/TextModLoader/TextModLoader.zip"
    },
    @{
        Name = "NoAds"
        Uri = "https://github.com/apple1417/bl-sdk-mods/raw/master/NoAds/NoAds.zip"
    }
)

# Download and extract each mod
foreach ($mod in $mods) {
    $modZip = Join-Path -Path $selectedPath -ChildPath ($mod.Name + ".zip")

    try {
        Invoke-WebRequest -Uri $mod.Uri -OutFile $modZip
        Expand-Archive -Path $modZip -DestinationPath (Join-Path -Path $selectedPath -ChildPath "Win32\mods") -Force
        Write-Host "Extracted mod: $($mod.Name)"
    } catch {
        Write-Host "Failed to download or extract $($mod.Name). Please check your internet connection and try again."
    }

    Remove-Item -Path $modZip -Force
    Write-Host "Removed file: $modZip"
}
