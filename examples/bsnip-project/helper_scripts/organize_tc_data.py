import numpy as np
import os
import scipy.io


def load_subject_timecourses(paths_string, labels_dict):
	file_paths = open(paths_string, 'r').read().split(',')

	ix = 0


	num_subs, num_components, num_timepoints = get_info(labels_dict, file_paths[0])

	tc_concat = np.zeros((num_subs, num_components, num_timepoints))

	labels = np.zeros(num_subs)
			
			
	for path in file_paths:
		try:
			if not os.path.isfile(path):
				print(f"Warning: subject time course file not found. {path}")

			# Load subject TC matrix
			data = scipy.io.loadmat(path)
			matrix = data['TCMax'] #(162, 53)
			if(matrix.shape[1] == 53):
				matrix = matrix.T #(53, 162)



			# Extract Subject ID, assumes this format TCOutMax_000300655084.mat
			strings = path.split('/')
			strings = strings[len(strings)-1].split('_')
			strings = strings[len(strings)-1].split('.')
			sub_id = strings[0]
			print(f'subject id {sub_id}')

			if(sub_id in labels_dict.keys()):

				# Get diagnosis of subject
				labels[ix] = labels_dict[sub_id]

				# Put subject TCs into tensor
				tc_concat[ix] = matrix
				ix += 1
			else:
				continue

		except:
			print(f"Exception in subject {sub_id}, filepath is: {path}")

	return tc_concat, labels


def get_info(labels_dict, path):
	data = scipy.io.loadmat(path)
	matrix = data['TCMax'] #(num_timepoints, 53)
	if(matrix.shape[1] == 53):
		matrix = matrix.T #(53, num_timepoints)

	n_comp, n_tp = matrix.shape
	n_subs = len(labels_dict.keys())
	return n_subs, n_comp, n_tp


labels_dict = np.load('/data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/labels.npy',allow_pickle='TRUE').item()
paths_string = '/data/users2/jwardell1/nshor_docker/examples/bsnip-project/BSNIP/Boston/time_courses_files.txt'
tc_concat, labels = load_subject_timecourses(paths_string, labels_dict)
data_dict = {
	'data'   : tc_concat,
	'labels' : labels
}
np.save('tc_data_dict.npy', data_dict)
