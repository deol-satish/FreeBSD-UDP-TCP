import re
import pandas as pd
import os
import csv
import sys


def extract_udp_prague_to_dataframe(input_txt_file):
    """
    Extracts UDP Prague receiver log entries from a text file into a pandas DataFrame.

    Args:
        input_txt_file (str): Path to the input log file.

    Returns:
        pd.DataFrame: DataFrame containing parsed log entries.
    """
    if not os.path.exists(input_txt_file):
        raise FileNotFoundError(f"File '{input_txt_file}' not found.")

    # Regex to match [RECVER] lines
    pattern = re.compile(
        r"\[RECVER\]: ([\d.]+) sec, Rcvd: ([\d.]+) Mbps, Sent: ([\d.]+) Mbps, "
        r"RTT: ([\d.]+) ms, Mark: ([\d.\-]+)%\((\-?\d+)/(\d+)\), Lost: ([\d.\-]+)%\((\-?\d+)/(\d+)\)"
    )

    records = []

    with open(input_txt_file, "r") as f:
        for line in f:
            match = pattern.search(line)
            if match:
                records.append(match.groups())

    # Column names
    columns = [
        "Time", "Rcvd_Mbps", "Sent_Mbps", "RTT_ms",
        "Mark_pct", "Mark_Marked", "Mark_Total",
        "Lost_pct", "Lost_Lost", "Lost_Total"
    ]

    

    # Convert to DataFrame
    df = pd.DataFrame(records, columns=columns)

    df['Time'] = df['Time'].astype('float64')

    df['Time'] -= df['Time'].iloc[0]

    # Convert numeric columns from strings to appropriate types
    numeric_cols = df.columns
    df[numeric_cols] = df[numeric_cols].apply(pd.to_numeric, errors='coerce')

    return df


def extract_udp_prague_log_to_csv(input_txt_file, output_csv_file=None):
    if not os.path.exists(input_txt_file):
        print(f"Error: File '{input_txt_file}' not found.")
        return

    # Set default output filename if not provided
    if output_csv_file is None:
        output_csv_file = os.path.splitext(input_txt_file)[0] + "_parsed.csv"

    # Regex pattern for extracting log data
    pattern = re.compile(
        r"\[RECVER\]: ([\d.]+) sec, Rcvd: ([\d.]+) Mbps, Sent: ([\d.]+) Mbps, "
        r"RTT: ([\d.]+) ms, Mark: ([\d.\-]+)%\((\-?\d+)/(\d+)\), Lost: ([\d.\-]+)%\((\-?\d+)/(\d+)\)"
    )

    extracted_data = []

    with open(input_txt_file, "r") as infile:
        for line in infile:
            match = pattern.search(line)
            if match:
                extracted_data.append(match.groups())

    headers = [
        "Time(sec)", "Rcvd(Mbps)", "Sent(Mbps)", "RTT(ms)",
        "Mark(%)", "MarkMarked", "MarkTotal", "Lost(%)", "LostLost", "LostTotal"
    ]

    with open(output_csv_file, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(headers)
        writer.writerows(extracted_data)

    print(f"✅ Data extracted to: {output_csv_file}")

