import os
import shutil
import requests
import zipfile

def get_directory_path():
    prompt_message = "Enter '2' for Borderlands 2, 'TPS' for Borderlands: The Pre-Sequel, 'AODK' for Assault on Dragon Keep:"
    default_path_bl2 = r"C:\Program Files (x86)\Steam\steamapps\common\Borderlands 2"
    default_path_tps = r"C:\Program Files (x86)\Steam\steamapps\common\BorderlandsPreSequel"
    default_path_aodk = r"C:\Program Files (x86)\Steam\steamapps\common\Pawpaw"

    default_paths = {
        '2': default_path_bl2,
        'TPS': default_path_tps,
        'AODK': default_path_aodk
    }

    while True:
        user_choice = input(prompt_message)
        if user_choice in default_paths:
            break

    selected_path = input(f"Enter the path to your {user_choice} folder and press Enter or press Enter for the default steam install dir: ")

    if not selected_path:
        selected_path = default_paths[user_choice]

    while not os.path.exists(selected_path):
        print("The directory does not exist. Please try again.")
        selected_path = input(f"Enter the path to your {user_choice} folder and press Enter or press Enter for the default steam install dir: ")

        if not selected_path:
            selected_path = default_paths[user_choice]

    return os.path.join(selected_path, "Binaries")

# Call the function to get the directory path from the user and add "/Binaries" to the path
selected_path = get_directory_path()

# Download and extract pythonsdk
pythonsdk_uri = "https://github.com/SirGamers/bl2automod/raw/main/a.zip"
pythonsdk_zip = os.path.join(selected_path, "a.zip")

try:
    response = requests.get(pythonsdk_uri)
    with open(pythonsdk_zip, 'wb') as file:
        file.write(response.content)

    with zipfile.ZipFile(pythonsdk_zip, 'r') as zip_ref:
        zip_ref.extractall(os.path.join(selected_path, "Win32"))
    print("Downloaded and extracted pythonsdk")
except Exception as e:
    print("Failed to download or extract pythonsdk. Please check your internet connection and try again.")
    print(f"Error: {e}")

os.remove(pythonsdk_zip)
print(f"Removed file: {pythonsdk_zip}")

# Define the list of mods to download and extract
mods = [
    {
        'Name': "TextModLoader",
        'Uri': "https://github.com/apple1417/bl-sdk-mods/raw/master/TextModLoader/TextModLoader.zip"
    },
    {
        'Name': "NoAds",
        'Uri': "https://github.com/apple1417/bl-sdk-mods/raw/master/NoAds/NoAds.zip"
    }
]

# Download and extract each mod
for mod in mods:
    mod_zip = os.path.join(selected_path, f"{mod['Name']}.zip")

    try:
        response = requests.get(mod['Uri'])
        with open(mod_zip, 'wb') as file:
            file.write(response.content)

        with zipfile.ZipFile(mod_zip, 'r') as zip_ref:
            zip_ref.extractall(os.path.join(selected_path, "Win32", "mods"))
        print(f"Extracted mod: {mod['Name']}")
    except Exception as e:
        print(f"Failed to download or extract {mod['Name']}. Please check your internet connection and try again.")
        print(f"Error: {e}")

    os.remove(mod_zip)
    print(f"Removed file: {mod_zip}")
