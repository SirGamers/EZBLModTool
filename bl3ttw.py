import os
import shutil
import requests
import zipfile

def get_game_selection(prompt_message="Please select a game: Borderlands 3 (B) or Tiny Tina's Wonderlands (T)", default_game="B"):
    user_input = input(prompt_message).upper() or default_game
    while user_input not in ('B', 'T'):
        print("Invalid selection. Please select 'B' for Borderlands 3 or 'T' for Tiny Tina's Wonderlands.")
        user_input = input(prompt_message).upper() or default_game
    return user_input

def get_directory_path(game_selection, default_path):
    prompt_message = f"Press enter if your {game_selection} folder is stored at {default_path}, otherwise type in the path to {game_selection} and press enter."
    user_input = input(prompt_message) or default_path
    while not os.path.exists(user_input):
        print("The directory does not exist. Please try again.")
        user_input = input(prompt_message) or default_path
    return user_input

def download_and_extract_file(url, destination_path):
    try:
        response = requests.get(url, stream=True)
        downloaded_file = os.path.join(destination_path, os.path.basename(url))
        with open(downloaded_file, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)

        with zipfile.ZipFile(downloaded_file, 'r') as zip_ref:
            zip_ref.extractall(destination_path)

        os.remove(downloaded_file)
    except Exception as e:
        print(f"Failed to download or extract file from {url}: {e}")

def remove_files_in_selected_path(selected_path, file_names):
    for file_name in file_names:
        file_path = os.path.join(selected_path, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"Removed file: {file_path}")
        else:
            print(f"File not found: {file_path}")

# Call the function to get the game selection
selected_game = get_game_selection()

# Set the default path based on the selected game
default_path = (
    "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Tiny Tina's Wonderlands"
    if selected_game == 'T'
    else "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Borderlands 3"
)

# Call the function to get the selected path based on the game selection and default path
selected_path = get_directory_path(selected_game, default_path)

# Define the file URLs and names to be removed
bl3_dx11_injection_url = "https://github.com/FromDarkHell/BL3DX11Injection/releases/download/v1.1.3/D3D11.zip"
open_hotfix_loader_url = "https://github.com/apple1417/OpenHotfixLoader/releases/download/v1.6/OpenHotfixLoader.zip"
file_names_to_remove = ["a.zip", "b.zip"]
file_name_to_remove = "LICENSE"

# Download and extract bl3dx11injection
download_and_extract_file(bl3_dx11_injection_url, os.path.join(selected_path, "Win64"))

# Download and extract openhotfixloader
download_and_extract_file(open_hotfix_loader_url, os.path.join(selected_path, "Win64", "Plugins"))

# Call the function to remove files
remove_files_in_selected_path(selected_path, file_names_to_remove)

# Call the function to remove a file from a different directory
remove_files_in_selected_path(os.path.join(selected_path, "Win64", "Plugins"), [file_name_to_remove])
