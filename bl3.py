import os
import shutil
import requests
from zipfile import ZipFile

def get_directory_path(prompt_message="Press enter if your Borderlands 3 folder is stored at C:\\Program Files (x86)\\Steam\\steamapps\\common\\Borderlands 3, otherwise type in the path to BL3 and press enter",
                       default_path="C:\\Program Files (x86)\\Steam\\steamapps\\common\\Borderlands 3"):
    while True:
        user_input = input(prompt_message) or default_path
        if os.path.exists(user_input):
            break
        print("The directory does not exist. Please try again.")

    return os.path.join(user_input, "OakGame", "Binaries")

def download_and_extract_file(url, destination_path):
    try:
        with requests.get(url, stream=True) as response:
            response.raise_for_status()
            with open(destination_path, "wb") as f:
                shutil.copyfileobj(response.raw, f)

        with ZipFile(destination_path, "r") as zip_ref:
            zip_ref.extractall(destination_path)

        os.remove(destination_path)
    except requests.exceptions.RequestException as e:
        print(f"Failed to download or extract file from {url}: {e}")

def remove_files_in_selected_path(selected_path):
    file_names_to_remove = ["a.zip", "b.zip"]
    for file_name in file_names_to_remove:
        file_path = os.path.join(selected_path, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"Removed file: {file_path}")
        else:
            print(f"File not found: {file_path}")

def remove_file_from_different_directory(selected_path):
    file_name_to_remove = "LICENSE"
    file_path = os.path.join(selected_path, "Win64", "Plugins", file_name_to_remove)
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"Removed file: {file_path}")
    else:
        print(f"File not found: {file_path}")

def main():
    selected_path = get_directory_path()

    # Define the file URLs
    bl3_dx11_injection_url = "https://github.com/FromDarkHell/BL3DX11Injection/releases/download/v1.1.3/D3D11.zip"
    open_hotfix_loader_url = "https://github.com/apple1417/OpenHotfixLoader/releases/download/v1.6/OpenHotfixLoader.zip"

    # Download and extract bl3dx11injection
    download_and_extract_file(bl3_dx11_injection_url, os.path.join(selected_path, "Win64"))

    # Download and extract openhotfixloader
    download_and_extract_file(open_hotfix_loader_url, os.path.join(selected_path, "Win64", "Plugins"))

    # Call the function to remove files
    remove_files_in_selected_path(selected_path)

    # Call the function to remove a file from a different directory
    remove_file_from_different_directory(selected_path)

if __name__ == "__main__":
    main()

