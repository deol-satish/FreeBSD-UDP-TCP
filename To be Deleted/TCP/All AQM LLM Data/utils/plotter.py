import matplotlib.pyplot as plt
import os
from utils.config import colors, markers, linestyles, DPI, SAVE_FORMATS, bar_width as global_bar_width , figsize as global_figsize, title_req
import seaborn as sns
import pandas as pd

# Function to save the plot in different formats
def save_plot(fig, filename, folder):
    """Save a plot in multiple formats."""
    os.makedirs(folder, exist_ok=True)
    for fmt in SAVE_FORMATS:
        fig.savefig(f"{folder}/{filename}.{fmt}", dpi=DPI, bbox_inches='tight')


def plot_siftr_graph(paths, ycolumn, title, xlabel, ylabel, filename, graph_directory):
    """Plot a graph from Siftr log files."""
    sns.set_style("darkgrid")
    fig, ax = plt.subplots(figsize=global_figsize)

    
    for i, (path_label, path_df) in enumerate(paths.items()):
        # print("i:,",i)
        # print("colors[i]",colors[i])
        # print("path_label",path_label)
        ax.plot(path_df['Time'], path_df[ycolumn], label=path_label, color=colors[i],marker=markers[i],linestyle=linestyles[i])

    if not title_req:
        title = ""

    # Set plot properties
    ax.set(title=title, xlabel=xlabel, ylabel=ylabel)
    ax.legend()
    ax.grid(True)
    
    # Tight layout and save the plot
    plt.tight_layout()
    # print("folder save", graph_directory)
    save_plot(fig, filename, graph_directory)
    plt.show()
    plt.close(fig)