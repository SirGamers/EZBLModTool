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

    # add \OakGame\Binaries to the path
    $additionalDirectory = "OakGame\Binaries"
    $selectedPath = Join-Path -Path $userInput -ChildPath $additionalDirectory

    return $selectedPath
}

# Call the function
$selectedPath = Get-DirectoryPath

# download and extract bl3dx11injection
Invoke-WebRequest -uri "https://github.com/FromDarkHell/BL3DX11Injection/releases/download/v1.1.3/D3D11.zip" -OutFile $selectedPath\a.zip
Expand-Archive $selectedPath\a.zip -DestinationPath $selectedPath\Win64\

# download and extract openhotfixloader
Invoke-WebRequest -uri "https://github.com/apple1417/OpenHotfixLoader/releases/download/v1.6/OpenHotfixLoader.zip" -OutFile $selectedPath\b.zip
Expand-Archive $selectedPath\b.zip -DestinationPath $selectedPath\Win64\Plugins

#remove ohl and bl3dx11injection zip files (function #2)
function Remove-FilesInSelectedPath {
    param (
        [string]$selectedPath
    )

    # Define the list of file names to be removed from the selectedPath
    $fileNamesToRemove = @("a.zip", "b.zip")

    # Loop through the list and remove each file from selectedPath
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

#remove ohl LICENSE file (function #3)
function Remove-FileFromDifferentDirectory {
    param (
        [string]$selectedPath
    )

    # Define the file name to be removed from a different directory within selectedPath
    $fileNameToRemove = "LICENSE"

    # Create the full path to the file
    $filePath = Join-Path -Path (Join-Path -Path $selectedPath -ChildPath "\Win64\Plugins") -ChildPath $fileNameToRemove

    if (Test-Path $filePath) {
        Remove-Item $filePath -Force
        Write-Host "Removed file: $filePath"
    } else {
        Write-Host "File not found: $filePath"
    }
}

# call function #2
Remove-FilesInSelectedPath -selectedPath $selectedPath

# call function #3
Remove-FileFromDifferentDirectory -selectedPath $selectedPath
