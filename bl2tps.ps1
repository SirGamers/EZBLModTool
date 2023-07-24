function Get-DirectoryPath {
    param (
        [string]$promptMessage = "Enter '2' for Borderlands 2, 'TPS' for Borderlands: The Pre-Sequel:",
        [string]$defaultPathBL2 = "C:\Program Files (x86)\Steam\steamapps\common\Borderlands 2",
        [string]$defaultPathTPS = "C:\Program Files (x86)\Steam\steamapps\common\Borderlands The Pre-Sequel"
    )

    # Prompt the user for input
    do {
        $userChoice = Read-Host -Prompt $promptMessage
    } while ($userChoice -notmatch '^(2|TPS)$')

    # Set the path based on the user's choice or use the default path
    $selectedPath = switch ($userChoice) {
        '2' { Read-Host "Enter the path to your Borderlands 2 folder and press Enter or press Enter for the default steam install dir" }
        'TPS' { Read-Host "Enter the path to your Borderlands: The Pre-Sequel folder and press Enter or press Enter for the default steam install dir" }
    }

    if ([string]::IsNullOrEmpty($selectedPath)) {
        $selectedPath = switch ($userChoice) {
            '2' { $defaultPathBL2 }
            'TPS' { $defaultPathTPS }
        }
    }

    # Check if the directory path exists, otherwise keep prompting
    while (-not (Test-Path -Path $selectedPath -PathType Container)) {
        Write-Host "The directory does not exist. Please try again."
        $selectedPath = switch ($userChoice) {
            '2' { Read-Host "Enter the path to your Borderlands 2 folder and press Enter or press Enter for the default steam install dir" }
            'TPS' { Read-Host "Enter the path to your Borderlands: The Pre-Sequel folder and press Enter or press Enter for the default steam install dir" }
        }

        if ([string]::IsNullOrEmpty($selectedPath)) {
            $selectedPath = switch ($userChoice) {
                '2' { $defaultPathBL2 }
                'TPS' { $defaultPathTPS }
            }
        }
    }

    # Add /Binaries to the path
    $additionalDirectory = "Binaries"
    $selectedPath = Join-Path -Path $selectedPath -ChildPath $additionalDirectory

    return $selectedPath
}

# Call the function to get the directory path from the user and add "/Binaries" to the path
$selectedPath = Get-DirectoryPath

# Download and extract pythonsdk
$pythonsdkUri = "https://github.com/SirGamers/bl2automod/raw/main/a.zip"
$pythonsdkZip = Join-Path -Path $selectedPath -ChildPath "a.zip"
Invoke-WebRequest -Uri $pythonsdkUri -OutFile $pythonsdkZip
Expand-Archive -Path $pythonsdkZip -DestinationPath $selectedPath\Win32 -Force
Write-Host "Downloaded and extracted pythonsdk"
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
    Invoke-WebRequest -Uri $mod.Uri -OutFile $modZip
    Expand-Archive -Path $modZip -DestinationPath $selectedPath\Win32\mods -Force
    Write-Host "Extracted mod: $($mod.Name)"
    Remove-Item -Path $modZip -Force
    Write-Host "Removed file: $modZip"
}
