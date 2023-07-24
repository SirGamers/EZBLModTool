function Get-DirectoryPath {
    param (
        [string]$promptMessage = "Press enter if your Borderlands Pre-Sequel folder is stored at C:\Program Files (x86)\Steam\steamapps\common\BorderlandsPreSequel, otherwise type in the path to TPS and press enter",
        [string]$defaultPath = "C:\Program Files (x86)\Steam\steamapps\common\BorderlandsPreSequel"
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

    # add /Binaries to the path
    $additionalDirectory = "Binaries"
    $selectedPath = Join-Path -Path $userInput -ChildPath $additionalDirectory

    return $selectedPath
}

# Call the function to get the directory path from the user and add "/Binaries" to the path
$selectedPath = Get-DirectoryPath

# download and extract pythonsdk
Invoke-WebRequest -uri "https://github.com/SirGamers/bl2automod/raw/main/a.zip" -OutFile $selectedPath\a.zip
Expand-Archive $selectedPath\a.zip -DestinationPath $selectedPath\Win32

# download some mods that are basically needed
Invoke-WebRequest -uri "https://github.com/apple1417/bl-sdk-mods/raw/master/TextModLoader/TextModLoader.zip" -OutFile $selectedPath\b.zip
Expand-Archive $selectedPath\b.zip -DestinationPath $selectedPath\Win32\mods
Invoke-WebRequest -uri "https://github.com/apple1417/bl-sdk-mods/raw/master/NoAds/NoAds.zip" -OutFile $selectedPath\c.zip
Expand-Archive $selectedPath\c.zip -DestinationPath $selectedPath\Win32\mods

# function to remove the zips afterwards
function Remove-FilesInSelectedPath {
    param (
        [string]$selectedPath
    )

    # Define the list of file names to be removed
    $fileNamesToRemove = @("a.zip", "b.zip", "c.zip")

    # Loop through the list and remove each file
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

# call the function
Remove-FilesInSelectedPath -selectedPath $selectedPath