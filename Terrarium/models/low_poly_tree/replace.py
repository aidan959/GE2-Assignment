import os
import subprocess

def convert_fbx_to_gltf(fbx_file, delete_original=False):
    """
    Converts an FBX file to a GLTF file using FBX2glTF converter.
    
    Parameters:
    fbx_file (str): The path to the FBX file.
    delete_original (bool): If True, the original FBX file will be deleted after conversion.
    """
    # Define the output GLTF file name
    gltf_file = f"{os.path.splitext(fbx_file)[0]}.gltf"
    
    # Command to convert FBX to GLTF
    command = ["FBX2glTF-windows-x86_64.exe", "-i", fbx_file, "-b", "-o", os.path.splitext(fbx_file)[0]]
    
    
    # Execute the conversion command
    try:
        subprocess.run(command, check=True)
        print(f"Converted '{fbx_file}' to '{gltf_file}'.")
        
        # If conversion is successful and delete_original is True, delete the FBX file
        if delete_original:
            os.remove(fbx_file)
            print(f"Deleted original file: {fbx_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error during conversion: {e}")

def main():
    # Get all FBX files in the current directory
    for filename in os.listdir('.'):
        if filename.lower().endswith('.fbx'):
            convert_fbx_to_gltf(filename, delete_original = False)

if __name__ == "__main__":
    main()
