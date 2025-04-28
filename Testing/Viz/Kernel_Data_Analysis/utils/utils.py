import os
import pandas as pd
import re
def find_files_with_extension(paths=['./'], extension='.log'):
    file_paths = []
    file_names = []
    file_dict = {}

    for path in paths:
        for root, _, files in os.walk(path):
            for file in files:
                if file.endswith(extension):
                    full_file_path = os.path.join(root, file)
                    file_names.append(file)
                    file_paths.append(full_file_path)
                    file_dict[file] = full_file_path


    return file_names, file_paths, file_dict

def get_stats(df, column):
    median = df[column].median()
    mean = df[column].mean()
    q25 = df[column].quantile(0.25)
    q75 = df[column].quantile(0.75)
    minimum = df[column].min()
    maximum = df[column].max()

    # Printing all the values
    print(f"Median: {median}")
    print(f"Mean: {mean}")
    print(f"25th Percentile (Q1): {q25}")
    print(f"75th Percentile (Q3): {q75}")
    print(f"Minimum: {minimum}")
    print(f"Maximum: {maximum}")


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