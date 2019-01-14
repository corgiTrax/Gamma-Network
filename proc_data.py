import scipy.io as sio
import numpy as np
import copy
import  sys
import matplotlib.pyplot as plt

'''
Note: not all trials have spikes
'''

class Trace:
	def __init__(self, trace_data_):
		'''Commented fields are not needed for current project'''
		trace_data = trace_data_
		print("=" * 100)
		# Naming convention is consistent with the original file header
		self.trace_name = trace_data[0][0]
		print("traceName: %s" % self.trace_name)
		self.trace_start_t_stamp = trace_data[1][0]
		print("traceStartTStamp: %s" % self.trace_start_t_stamp)
#		self.trace = trace_data[2]
#		print("trace: ")
#		print(self.trace)
		self.filtered_trace = trace_data[3]
		self.stim_time = trace_data[4]
#		self.threshold = trace_data[5]
		self.spike_peak_indexes = trace_data[6][0]
#		self.LFPTrace = trace_data[7]
		if len(self.spike_peak_indexes) == 0:
			print("!!!Warning: this trace does not contain splikes!!!")
		
		self.trace_len = len(self.filtered_trace)

	def plotFilteredTrace(self, start=0, end=None):
		if end is None:
			end = self.trace_len
		plt.plot(self.filtered_trace[start:end])
		plt.xlabel("Time: 1/20,000 second")
		plt.ylabel("mV")
		plt.show()
	
	def extractFreq(self, low, high):
		pass


class Trial:
	def __init__(self, fname):
		data = sio.loadmat(fname)
		print("Loading file %s" % fname)
		sTraceSerie_trace = data["sTraceSerie"]["trace"]
		sTraceSerie_trace_header = sTraceSerie_trace[0,0].dtype.fields.keys()
		print(sTraceSerie_trace_header)
		sTraceSerie_trace_data = sTraceSerie_trace[0,0]
		self.num_traces = sTraceSerie_trace_data.shape[1]
		print("# of traces: %s" % self.num_traces)
		
		# a list to store all traces
		self.traces = []
		for i in range(0,2): #TODO
			new_trace = Trace(sTraceSerie_trace_data[0,i])
			self.traces.append(copy.deepcopy(new_trace))

	def getTraceByIndex(self, index):
		pass


if __name__ == '__main__':
	print("Usage: %s data_mat_file_name")
	if len(sys.argv) < 2:
		sys.exit(0)
	test_trial = Trial(sys.argv[1])
	test_trial.traces[1].plotFilteredTrace()