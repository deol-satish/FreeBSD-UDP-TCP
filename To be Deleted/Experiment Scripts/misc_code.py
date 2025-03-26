import re
import os

def extract_unique_mbps_and_ms(directories):
    # Regex pattern to match 'XMbps_yms' and capture X (Mbps value) and y (ms value)
    pattern = re.compile(r'(\d+)Mbps_(\d+)ms')
    
    # Set to hold unique pairs of (Mbps, ms) combinations
    unique_combinations = set()

    # Iterate through all provided directories
    for directory in directories:
        # Ensure the directory exists
        if not os.path.exists(directory):
            print(f"Warning: Directory {directory} does not exist.")
            continue

        # Iterate through all files in the current directory
        for filename in os.listdir(directory):
            match = pattern.search(filename)
            if match:
                # Extract the values for X (Mbps) and y (ms) from the match groups
                mbps = match.group(1)
                ms = match.group(2)
                # Add the combination as a tuple (Mbps, ms) to the set (duplicates are ignored)
                unique_combinations.add((mbps, ms))

    return unique_combinations

# List of directories to search
directories = [
    r'G:\Github\FreeBSD-EXP-Condensed\Experiment Scripts\datatest1',
    r'G:\AnotherDirectory',  # Add more directories as needed
    # Add more directories here...
]

# Call the function and print unique combinations
unique_combinations = extract_unique_mbps_and_ms(directories)
print("Unique Mbps and ms Combinations:")
for mbps, ms in sorted(unique_combinations):
    print(f'{mbps} Mbps, {ms} ms')
