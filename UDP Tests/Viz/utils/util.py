import os
import pandas as pd
from utils.config import siftr_col
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

def print_rtt_stats(paths,scenario):
    print()
    print("RTT *-*-*"*5)
    print(f"RTT statistics in millisecond (ms) for scenario {scenario}:")
    for i, (path_label, path_df) in enumerate(paths.items()):
        statistics = calculate_statistics(path_df)
        print(f"Statistics for {path_label}:")
        for key, value in statistics.items():
            print(f"{key}: {value}")
    print("END RTT *-*-*"*5)
    print()

def return_rtt_stats(paths):
    return_stats = {}
    for i, (path_label, path_df) in enumerate(paths.items()):
        statistics = calculate_statistics(path_df)
        return_stats[path_label] = statistics
    return return_stats

def save_rtt_stats(paths,scenario,stats_directory):
    print()
    stats_filename = f"{stats_directory}/scn_{scenario}_rtt_stats.txt"
    print(f"Saving RTT statistics in millisecond (ms) to {stats_filename}")
    with open(stats_filename, 'w') as f:
        for i, (path_label, path_df) in enumerate(paths.items()):
            statistics = calculate_statistics(path_df)
            f.write(f"Statistics in millisecond (ms) for {path_label}: \n")
            for key, value in statistics.items():
                f.write(f"{key}: {value}\n")
            f.write("\n")
    print()


def remove_outliers_iqr(df, column_name):
    """
    Remove outliers from a specified column in a DataFrame using the IQR method.
    
    Parameters:
    df (pd.DataFrame): The DataFrame.
    column_name (str): The name of the column from which to remove outliers.
    
    Returns:
    pd.DataFrame: The DataFrame with outliers removed.
    """
    Q1 = df[column_name].quantile(0.25)
    Q3 = df[column_name].quantile(0.75)
    IQR = Q3 - Q1
    
    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR
    
    return df[(df[column_name] >= lower_bound) & (df[column_name] <= upper_bound)]


def get_dataframe_from_filepath(logpath):
    data = []
    with open(logpath, 'r') as f:
        for line in f:
            cleaned_line = re.sub(r'\s', '', line)
            data.append(cleaned_line.split(','))
    
    # Remove header and footer lines
    print(logpath)
    data.pop(0)
    data.pop(-1)

    df = pd.DataFrame(data, columns=siftr_col)

    # Filter and process data
    df = df[df['Direction'] == 'o'].astype({'CongestionWindow': 'int32', 'Time': 'float64'})
    df['Time'] -= df['Time'].iloc[0]
    df['SmoothedRTT'] = df['SmoothedRTT'].astype('float64') / 1000
    return df


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

def calculate_statistics(df):
    median = df['SmoothedRTT'].median()
    mean = df['SmoothedRTT'].mean()
    q25 = df['SmoothedRTT'].quantile(0.25)
    q75 = df['SmoothedRTT'].quantile(0.75)
    minimum = df['SmoothedRTT'].min()
    maximum = df['SmoothedRTT'].max()
    
    return {
        'Median': median,
        'Mean': mean,
        '25th Percentile': q25,
        '75th Percentile': q75,
        'Minimum': minimum,
        'Maximum': maximum
    }


# Function to format y-axis labels with commas
def comma_format(x, pos):
    return f'{int(x):,}'


def create_directory_if_not_exists(directory_path):
    """Create a directory if it doesn't already exist."""
    if not os.path.exists(directory_path):
        os.makedirs(directory_path)
        print(f"Directory created: {directory_path}")
    else:
        print(f"Directory already exists: {directory_path}")