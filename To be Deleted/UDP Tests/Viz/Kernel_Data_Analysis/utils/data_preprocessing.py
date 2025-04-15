# data_preprocessing.py
import pandas as pd
import os

def l4s_pre_process_extract(input_file='./Data/llmrawdata.txt',aqm ='l4s', output_file='lmprocesseddata.txt'):
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


def fq_pie_pre_process_extract(input_file='./Data/llmrawdata.txt',aqm ='l4s', output_file='lmprocesseddata.txt'):
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
    
    # column_list = [
    #     "queue_type", "qdelay_reference", "tupdate", "max_burst", "max_ecn_threshold", 
    #     "alpha_coefficient", "beta_coefficient", "flags", "burst_allowance", "drop_probability", 
    #     "current_queue_delay", "previous_queue_delay", "accumulated_probability", "measurement_start_time", 
    #     "average_dequeue_time", "dequeue_count", "status_flags", "total_packets", "total_bytes", 
    #     "queue_length", "length_in_bytes", "total_drops", "packet_length", "dequeue_action"
    # ]

    column_list = [
        "qdelay_reference", "tupdate", "max_burst", "max_ecn_threshold", 
        "alpha_coefficient", "beta_coefficient", "flags", "burst_allowance", "drop_probability", 
        "current_queue_delay", "previous_queue_delay", "accumulated_probability", "measurement_start_time", 
        "average_dequeue_time", "dequeue_count", "status_flags", "total_packets", "total_bytes", 
        "queue_length", "length_in_bytes", "total_drops", "dequeue_action"
    ]

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
