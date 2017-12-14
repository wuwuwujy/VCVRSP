import matplotlib.pyplot as plt
import numpy
import scipy
from scipy import signal
from sklearn.decomposition import FastICA, PCA
j=0
mat1=[]
class MyOVBox(OVBox):
	def __init__(self):
		OVBox.__init__(self)
		self.signalHeader = None

		
	def process(self):
		
		global j
		global mat1
	
		for chunkIndex in range( len(self.input[0]) ):
		
			if(type(self.input[0][chunkIndex]) == OVSignalHeader):
				self.signalHeader = self.input[0].pop()
				print(self.signalHeader.dimensionSizes)
				self.output[0].append(self.signalHeader)
				print(self.signalHeader.samplingRate)
				#print(self.signalHeader.dimensionSizes)
				
			elif(type(self.input[0][chunkIndex]) == OVSignalBuffer):
				chunk = self.input[0].pop()
				numpyBuffer = numpy.transpose(numpy.array(chunk).reshape(tuple(self.signalHeader.dimensionSizes)))
				shape=numpyBuffer.shape
				b=signal.firwin(len(numpyBuffer),[0.002,0.090],nyq=256)

				#numpyBuffer=signal.convolve(numpyBuffer,b,mode="full")
				for i in range (shape[1]):
					numpyBuffer[:,i]=signal.convolve(numpyBuffer[:,i],b,mode="same")
					#numpyBuffer[:,i]=signal.lfilter(b, [1.0], numpyBuffer[:,i])
					
					
				X=[]
					#print(mat1)
				X=numpyBuffer
				#X=X.reshape(self.signalHeader.dimensionSizes[0]*self.signalHeader.dimensionSizes[1],)
				Y=[]
				for j in range(0,self.signalHeader.dimensionSizes[0]):
					Y=Y+map(lambda x: x[j],X)

				chunk = OVSignalBuffer(chunk.startTime, chunk.endTime, list(Y))
				self.output[0].append(chunk)
			elif(type(self.input[0][chunkIndex]) == OVSignalEnd):
				self.output[0].append(self.input[0].pop())
			
 			j+=1

box = MyOVBox()

				
					

		
