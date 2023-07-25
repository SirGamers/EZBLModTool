function Get-GameSelection {
    param (
        [string]$promptMessage = "Please select a game: Borderlands 3 (B) or Tiny Tina's Wonderlands (T)",
        [string]$defaultGame = "B"
    )

    # Prompt the user for input
    $userInput = Read-Host -Prompt $promptMessage

    # If no input provided, use the default game
    if ([string]::IsNullOrEmpty($userInput)) {
        $userInput = $defaultGame
    }

    # Check if the user selected "Borderlands 3" or "Tiny Tina's Wonderlands"
    while ($userInput -notin @('B', 'T')) {
        Write-Host "Invalid selection. Please select 'B' for Borderlands 3 or 'T' for Tiny Tina's Wonderlands."
        $userInput = Read-Host -Prompt $promptMessage

        if ([string]::IsNullOrEmpty($userInput)) {
            $userInput = $defaultGame
        }
    }

    # Return the selected game as a string (either "Borderlands 3" or "Tiny Tina's Wonderlands")
    return $userInput
}

function Get-DirectoryPath {
    param (
        [string]$gameSelection,
        [string]$defaultPath
    )

    $promptMessage = "Press enter if your $($gameSelection) folder is stored at $defaultPath, otherwise type in the path to $($gameSelection) and press enter."

    # Prompt the user for input
    $userInput = Read-Host -Prompt $promptMessage

    # If no input provided, use the default path
    if ([string]::IsNullOrEmpty($userInput)) {
        $userInput = $defaultPath
    }

    # Check if the directory path exists, otherwise keep prompting
    while (-not (Test-Path -Path $userInput -PathType Container)) {
        Write-Host "The directory does not exist. Please try again."
        $userInput = Read-Host -Prompt $promptMessage

        if ([string]::IsNullOrEmpty($userInput)) {
            $userInput = $defaultPath
        }
    }

    return $userInput
}

function Download-AndExtractFile {
    param (
        [string]$url,
        [string]$destinationPath
    )

    try {
        # Download the file
        $downloadedFile = Join-Path -Path $destinationPath -ChildPath (Split-Path -Leaf $url)
        Invoke-WebRequest -Uri $url -OutFile $downloadedFile

        # Extract the file
        Expand-Archive -Path $downloadedFile -DestinationPath $destinationPath -Force

        # Remove the downloaded zip file
        Remove-Item $downloadedFile -Force
    } catch {
        Write-Host "Failed to download or extract file from $url"
    }
}

function Remove-FilesInSelectedPath {
    param (
        [string]$selectedPath,
        [string[]]$fileNames
    )

    foreach ($fileName in $fileNames) {
        $filePath = Join-Path -Path $selectedPath -ChildPath $fileName

        if (Test-Path $filePath) {
            Remove-Item $filePath -Force
            Write-Host "Removed file: $filePath"
        } else {
            Write-Host "File not found: $filePath"
        }
    }
}

# Call the function to get the game selection
$selectedGame = Get-GameSelection

# Set the default path based on the selected game
$defaultPath = if ($selectedGame -eq 'T') {
    "C:\Program Files (x86)\Steam\steamapps\common\Tiny Tina's Wonderlands"
} else {
    "C:\Program Files (x86)\Steam\steamapps\common\Borderlands 3"
}

# Call the function to get the selected path based on the game selection and default path
$selectedPath = Get-DirectoryPath -gameSelection $selectedGame -defaultPath $defaultPath

# Define the file URLs and names to be removed
$bl3Dx11InjectionUrl = "https://github.com/FromDarkHell/BL3DX11Injection/releases/download/v1.1.3/D3D11.zip"
$openHotfixLoaderUrl = "https://github.com/apple1417/OpenHotfixLoader/releases/download/v1.6/OpenHotfixLoader.zip"
$fileNamesToRemove = @("a.zip", "b.zip")
$fileNameToRemove = "LICENSE"

# Download and extract bl3dx11injection
Download-AndExtractFile -url $bl3Dx11InjectionUrl -destinationPath $selectedPath\Win64

# Download and extract openhotfixloader
Download-AndExtractFile -url $openHotfixLoaderUrl -destinationPath (Join-Path -Path $selectedPath\Win64 -ChildPath "Plugins")

# Call the function to remove files
Remove-FilesInSelectedPath -selectedPath $selectedPath -fileNames $fileNamesToRemove

# Call the function to remove a file from a different directory
Remove-FilesInSelectedPath -selectedPath (Join-Path -Path $selectedPath\Win64 -ChildPath "Plugins") -fileNames $fileNameToRemove
