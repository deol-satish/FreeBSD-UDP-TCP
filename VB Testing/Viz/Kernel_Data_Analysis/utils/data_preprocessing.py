import pandas as pd
import os

import re

# Define the column list for reference (order matters for output)
column_list = [
    "queue_type", "qdelay_reference", "tupdate", "max_burst", "max_ecn_threshold", 
    "alpha_coefficient", "beta_coefficient", "flags", "burst_allowance", "drop_probability", 
    "current_queue_delay", "previous_queue_delay", "accumulated_probability", "measurement_start_time", 
    "average_dequeue_time", "dequeue_count", "status_flags", "total_packets", "total_bytes", 
    "queue_length", "length_in_bytes", "total_drops", "packet_length", "dequeue_action"
]

# column_list = [
#     "queue_type", "qdelay_reference", "tupdate", "max_burst", "max_ecn_threshold", 
#     "alpha_coefficient", "beta_coefficient", "flags", "burst_allowance", "drop_probability", 
#     "current_queue_delay", "previous_queue_delay", "accumulated_probability", "measurement_start_time", 
#     "average_dequeue_time", "dequeue_count", "status_flags", "total_packets", "total_bytes", 
#     "queue_length", "length_in_bytes", "total_drops", "dequeue_action"
# ]



# Define the regex pattern to capture the values between `dualpi2_ecn_marking-start` and `end`
pattern = re.compile(r"dualpi2_ecn_marking-start,([\d,]+),end")

def parse_line(line):
    """ Parse a line using regex and return the values as a dictionary. """
    match = pattern.search(line)
    if match:
        # Extract the captured group and split by commas
        values = match.group(1).split(',')
        # If the number of values matches the column list, create a dictionary
        if len(values) == len(column_list):
            return dict(zip(column_list, values))
    return None

def process_file(input_file, output_file):
    """ Process the input file and write structured output to the output file. """
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if 'dualpi2_ecn_marking-start' in line:
                result = parse_line(line)
                if result:
                    # Format the output as CSV-like for each matched line
                    outfile.write(','.join(result.values()) + '\n')

def dualpi2_pre_process_extract(input_file='./Data/llmrawdata.txt',aqm ='dualpi2', output_file='lmprocesseddata.csv'):
    """
    Process raw data, filter out unwanted parts, and save it to a new file.
    """

    process_file(input_file, output_file)
    


    df = pd.read_csv(
        output_file, 
        names=column_list, 
        header=None, 
        on_bad_lines='skip', 
        usecols=range(len(column_list))
    )

    columns_to_drop = [
        "qdelay_reference", "tupdate", "max_burst", "max_ecn_threshold", 
        "alpha_coefficient", "beta_coefficient", "flags"
    ]
    df = df.drop(columns=columns_to_drop)
    # Convert 'dequeue_action' to numeric, coercing errors to NaN
    df['dequeue_action'] = pd.to_numeric(df['dequeue_action'], errors='coerce')

    # Now perform the subtraction
    df['dequeue_action'] = df['dequeue_action'] - 1  
    os.remove(output_file)
    # df.to_csv(f'{aqm}_exp_pool.csv')
    return df


def fq_pie_pre_process_extract(input_file='./Data/llmrawdata.txt',aqm ='dualpi2', output_file='lmprocesseddata.txt'):
    """
    Process raw data, filter out unwanted parts, and save it to a new file.
    """
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if f'{aqm}_ecn_marking-start' in line:
                parts = line.split("-")
                if len(parts) > 1:
                    content = parts[1].strip()
                    if content.endswith('end'):
                        outfile.write(content[6:-4] + '\n')
    
    column_list = [
        "queue_type", "qdelay_reference", "tupdate", "max_burst", "max_ecn_threshold", 
        "alpha_coefficient", "beta_coefficient", "flags", "burst_allowance", "drop_probability", 
        "current_queue_delay", "previous_queue_delay", "accumulated_probability", "measurement_start_time", 
        "average_dequeue_time", "dequeue_count", "status_flags", "total_packets", "total_bytes", 
        "queue_length", "length_in_bytes", "total_drops", "packet_length", "dequeue_action"
    ]

    # column_list = [
    #     "qdelay_reference", "tupdate", "max_burst", "max_ecn_threshold", 
    #     "alpha_coefficient", "beta_coefficient", "flags", "burst_allowance", "drop_probability", 
    #     "current_queue_delay", "previous_queue_delay", "accumulated_probability", "measurement_start_time", 
    #     "average_dequeue_time", "dequeue_count", "status_flags", "total_packets", "total_bytes", 
    #     "queue_length", "length_in_bytes", "total_drops", "dequeue_action"
    # ]

    df = pd.read_csv(
        output_file, 
        names=column_list, 
        header=None, 
        on_bad_lines='skip', 
        usecols=range(len(column_list))
    )

    columns_to_drop = [
        "qdelay_reference", "tupdate", "max_burst", "max_ecn_threshold", 
        "alpha_coefficient", "beta_coefficient", "flags"
    ]
    df = df.drop(columns=columns_to_drop)
    df['dequeue_action'] = df['dequeue_action'] - 1    
    os.remove('lmprocesseddata.txt')
    df.to_csv(f'{aqm}_exp_pool.csv')
    return df

def trim_df(df, trim_percent=0.2):
    """
    Trims a DataFrame by the given percentage.
    """
    print("Old Shape:", df.shape)
    rows_to_trim = int(len(df) * trim_percent)
    trimmed_df = df.iloc[rows_to_trim:].reset_index(drop=True)
    print("New Shape:", trimmed_df.shape)
    return trimmed_df




