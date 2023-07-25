import os
import shutil
import requests
from zipfile import ZipFile

def get_directory_path(prompt_message="Enter '2' for Borderlands 2, 'TPS' for Borderlands: The Pre-Sequel:",
                       default_path_bl2="C:\\Program Files (x86)\\Steam\\steamapps\\common\\Borderlands 2",
                       default_path_tps="C:\\Program Files (x86)\\Steam\\steamapps\\common\\Borderlands The Pre-Sequel"):
    while True:
        user_choice = input(prompt_message)
        if user_choice in ['2', 'TPS']:
            break

    selected_path = input(f"Enter the path to your Borderlands {user_choice} folder and press Enter or press Enter for the default steam install dir: ")
    if not selected_path:
        selected_path = default_path_bl2 if user_choice == '2' else default_path_tps

    while not os.path.exists(selected_path):
        print("The directory does not exist. Please try again.")
        selected_path = input(f"Enter the path to your Borderlands {user_choice} folder and press Enter or press Enter for the default steam install dir: ")
        if not selected_path:
            selected_path = default_path_bl2 if user_choice == '2' else default_path_tps

    return os.path.join(selected_path, "Binaries")

def download_and_extract_file(url, destination_path):
    with requests.get(url, stream=True) as response:
        response.raise_for_status()
        with open(destination_path, "wb") as f:
            shutil.copyfileobj(response.raw, f)

    with ZipFile(destination_path, "r") as zip_ref:
        zip_ref.extractall(os.path.dirname(destination_path))

    os.remove(destination_path)

def main():
    selected_path = get_directory_path()

    # Download and extract pythonsdk
    pythonsdk_url = "https://github.com/SirGamers/bl2automod/raw/main/a.zip"
    pythonsdk_zip = os.path.join(selected_path, "a.zip")
    download_and_extract_file(pythonsdk_url, pythonsdk_zip)
    print("Downloaded and extracted pythonsdk")

    # Define the list of mods to download and extract
    mods = [
        {
            "Name": "TextModLoader",
            "Uri": "https://github.com/apple1417/bl-sdk-mods/raw/master/TextModLoader/TextModLoader.zip"
        },
        {
            "Name": "NoAds",
            "Uri": "https://github.com/apple1417/bl-sdk-mods/raw/master/NoAds/NoAds.zip"
        }
    ]

    # Download and extract each mod
    for mod in mods:
        mod_zip = os.path.join(selected_path, f"{mod['Name']}.zip")
        download_and_extract_file(mod["Uri"], mod_zip)
        print(f"Extracted mod: {mod['Name']}")

if __name__ == "__main__":
    main()
