import sys
import numpy as np
from scipy.io import loadmat
from scipy.stats import zscore
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

def compute_fnc(subject_id, timecourse_file, output_dir):
    try:
        print(f'subject id {subject_id}')
        print(f'timecourses file {timecourse_file}')
        print(f'output dir {output_dir}')
        
        # Load the timecourse file for the current subject
        timecourse_data = loadmat(timecourse_file)
        timecourses = timecourse_data['TCMax']  # Assuming 'TCMax' is the variable name in the .mat file

        if timecourses.shape[1] == 53:
            timecourses = timecourses.T  # Transpose the matrix if the shape is (162, 53)

        num_components = timecourses.shape[0]

        # Z-score normalization of timecourses
        zscored_timecourses = zscore(timecourses, axis=1)

        # Compute FNC matrix (correlation matrix of timecourses)
        fnc_matrix = np.corrcoef(zscored_timecourses)

        # Set diagonal elements to zero
        np.fill_diagonal(fnc_matrix, 0)

        # Create a custom red-white-blue colormap
        cmap_colors = [(0, 'blue'), (0.5, 'white'), (1, 'red')]
        custom_cmap = LinearSegmentedColormap.from_list('custom_RWB', cmap_colors)

        # Plot FNC matrix using the custom colormap
        plt.imshow(fnc_matrix, cmap=custom_cmap, vmin=-1, vmax=1)
        plt.colorbar()  # Add color bar for reference

        savename = '{}/{}_fnc.png'.format(output_dir, subject_id)
        plt.savefig(savename)

        print(f"FNC matrix computed and saved for subject {subject_id}")

    except FileNotFoundError:
        print(f"Timecourse file not found for subject {subject_id}")
    except KeyError:
        print(f"Could not find 'TCMax' variable in the .mat file for subject {subject_id}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <subject_id> <timecourse_file> <output_dir>")
    else:
        subject_id = sys.argv[1]
        timecourse_file = sys.argv[2]
        output_dir = sys.argv[3]
        compute_fnc(subject_id, timecourse_file, output_dir)
