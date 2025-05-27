# %%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import seaborn as sns


import time
import math
import random
import re
import os
import sys


from utils.util import find_files_with_extension , filter_strings_by_substrings, get_scenario_dict
from utils.util import  get_dataframe_from_filepath
from utils.util import create_directory_if_not_exists
from utils.udp_util import extract_udp_prague_to_dataframe
from utils.plotter import  plot_siftr_graph

# %%
# Load data
mainpth="../data/udp_data_2025-04-11"
mainpth="../data/udp_data_2025-04-27"
mainpth="../data/tcp_data_2025-05-03"


graph_directory = os.path.join(mainpth, "Graphs")
create_directory_if_not_exists(graph_directory)

stats_directory = os.path.join(mainpth, "Stats")
create_directory_if_not_exists(stats_directory)


folderpaths = [mainpth+'/client1_data', mainpth+'/client2_data']
filenames, filepaths, filedict = find_files_with_extension(folderpaths, '')


scenario_dict = get_scenario_dict(folderpaths)



# %%
for scenario in scenario_dict.keys():
    index = "1_dualpi2"

    search_list = ["1_dualpi2", "log", "txt"]
    print()
    print("Start New Scenario")
    print("Scenario", scenario)    

    my_list = scenario_dict[scenario]

    for i, item in enumerate(my_list, start=0):
        print(f"{i}. {item}")

# %%
for scenario in scenario_dict.keys():
    index = "1_dualpi2"

    search_list_tcp = [index, "log", "src"]
    filtered_tcp = filter_strings_by_substrings(scenario_dict[scenario], search_list_tcp)

    search_list_udp = [index, "udp_prague_receiver"]
    filtered_udp = filter_strings_by_substrings(scenario_dict[scenario], search_list_udp)

    print()
    print("Start New Scenario")
    print("Scenario", scenario)
    print(filtered_tcp)
    print(filtered_udp)


# %%
for scenario in scenario_dict.keys():
    index = "1_dualpi2"

    search_list_tcp = [index, "log", "src"]
    filtered_tcp = filter_strings_by_substrings(scenario_dict[scenario], search_list_tcp)

    search_list_udp = [index, "udp_prague_receiver"]
    filtered_udp = filter_strings_by_substrings(scenario_dict[scenario], search_list_udp)

    print()
    print("Start New Scenario")
    print("Scenario", scenario)
    print(filtered_tcp)
    print(filtered_udp)


    ttf1 = get_dataframe_from_filepath(filtered_tcp[0])
    ttf1 = ttf1[ttf1['ForeignPort'] == "5101"]
    ttf = get_dataframe_from_filepath(filtered_tcp[1])
    ttf2 = ttf[ttf['ForeignPort'] == "5102"]
    ttf3 = ttf[ttf['ForeignPort'] == "5103"]




        # Define paths
    paths = {
        "Cubic": ttf3,
        "DCTCP": ttf1,
        "NewReno": ttf2,
    }

    keys_string = "_".join(paths.keys())
    print(keys_string)

    scenario += str("_"+keys_string)

    plot_siftr_graph(paths=paths,
                    ycolumn="SmoothedRTT",
                    title=f"{scenario} SmoothedRTT",
                    xlabel="Time (s)",
                    ylabel="SmoothedRTT (ms)",
                    filename=f'{scenario}_SmoothedRTT',
                    graph_directory=graph_directory,
    )


# %%
os.path.getsize(filtered_tcp[0])


# %%
os.path.getsize(filtered_tcp[1])


