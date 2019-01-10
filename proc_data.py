import scipy.io as sio
import numpy as np
import copy
import  sys

'''
Note: not all trials have spikes
'''

class Trial:
	def __init__(self, fname):
		data = sio.loadmat(fname)
		print("Loading file %s" % fname)
		sTraceSerie_trace = data["sTraceSerie"]["trace"]
		sTraceSerie_trace_header = sTraceSerie_trace[0,0].dtype.fields.keys()
		print(sTraceSerie_trace_header)
		sTraceSerie_trace_data = sTraceSerie_trace[0,0]
		num_traces = sTraceSerie_trace_data.shape[1]
		print("# of traces: %s" % num_traces)
		first_trace = sTraceSerie_trace_data[0,0]
		print(first_trace)


	def plot(self):
		pass

	def extract_gamma(self):
		pass

	def extract_spike(self):
		pass


if __name__ == '__main__':
	print("Usage: %s data_mat_file_name")
	if len(sys.argv) < 2:
		sys.exit(0)
	test_trial = Trial(sys.argv[1])