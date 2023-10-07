function Get-DirectoryPath {
    param (
        [string]$promptMessage = "Press enter if your Borderlands 3 folder is stored at C:\Program Files (x86)\Steam\steamapps\common\Borderlands 3, otherwise type in the path to BL3 and press enter",
        [string]$defaultPath = "C:\Program Files (x86)\Steam\steamapps\common\Borderlands 3"
    )

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

    # Append \OakGame\Binaries to the path
    $additionalDirectory = "OakGame\Binaries"
    $selectedPath = Join-Path -Path $userInput -ChildPath $additionalDirectory

    return $selectedPath
}

# Call the function to get the selected path
$selectedPath = Get-DirectoryPath

# Define the file URLs
$bl3Dx11InjectionUrl = "https://github.com/FromDarkHell/BL3DX11Injection/releases/download/v1.1.3/D3D11.zip"
$openHotfixLoaderUrl = "https://github.com/apple1417/OpenHotfixLoader/releases/download/v1.6/OpenHotfixLoader.zip"

# Define the file names to be removed
$fileNamesToRemove = @("a.zip", "b.zip")

# Define the file name to be removed from a different directory
$fileNameToRemove = "LICENSE"

# Function to download and extract files
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

# Download and extract bl3dx11injection
Download-AndExtractFile -url $bl3Dx11InjectionUrl -destinationPath $selectedPath\Win64

# Download and extract openhotfixloader
Download-AndExtractFile -url $openHotfixLoaderUrl -destinationPath (Join-Path -Path $selectedPath\Win64 -ChildPath "Plugins")

# Function to remove files in the selected path
function Remove-FilesInSelectedPath {
    param (
        [string]$selectedPath
    )

    foreach ($fileName in $fileNamesToRemove) {
        $filePath = Join-Path -Path $selectedPath -ChildPath $fileName

        if (Test-Path $filePath) {
            Remove-Item $filePath -Force
            Write-Host "Removed file: $filePath"
        } else {
            Write-Host "File not found: $filePath"
        }
    }
}

# Function to remove a file from a different directory within selected path
function Remove-FileFromDifferentDirectory {
    param (
        [string]$selectedPath
    )

    $filePath = Join-Path -Path (Join-Path -Path $selectedPath -ChildPath "Win64\Plugins") -ChildPath $fileNameToRemove

    if (Test-Path $filePath) {
        Remove-Item $filePath -Force
        Write-Host "Removed file: $filePath"
    } else {
        Write-Host "File not found: $filePath"
    }
}

# Call the function to remove files
Remove-FilesInSelectedPath -selectedPath $selectedPath

# Call the function to remove a file from a different directory
Remove-FileFromDifferentDirectory -selectedPath $selectedPath
