import sys
import numpy as np
from scipy.io import loadmat
from scipy.stats import zscore
import matplotlib.pyplot as plt

def compute_fnc(subject_id, timecourse_file, output_dir, downsampling_factor):
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

	# Apply downsampling
        if downsampling_factor > 1:
            timecourses = timecourses[:, ::downsampling_factor]  # Downsample by taking every nth sample
            print(f"apply downsampling {downsampling_factor}")


        # Save FNC matrix to a file
        if downsampling_factor > 1:
            output_file = f'{output_dir}/FNC_{subject_id}_ds_{downsampling_factor}.npy'
        else:
            output_file = f'{output_dir}/FNC_{subject_id}.npy'
        
        np.save(output_file, fnc_matrix)

        plt.imshow(fnc_matrix)
        savename = '{}/{}_ds_{}_fnc.png'.format(output_dir, subject_id, downsampling_factor)
        plt.savefig(savename)
        
        print(f"FNC matrix computed and saved for subject {subject_id}")

    except FileNotFoundError:
        print(f"Timecourse file not found for subject {subject_id}")
    except KeyError:
        print(f"Could not find 'TCMax' variable in the .mat file for subject {subject_id}")

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python script.py <subject_id> <timecourse_file> <output_dir> <downsampling_factor>")
    else:
        subject_id = sys.argv[1]
        timecourse_file = sys.argv[2]
        output_dir = sys.argv[3]
        downsampling_factor = int(sys.argv[4])
        compute_fnc(subject_id, timecourse_file, output_dir, downsampling_factor)

