

class MyOVBox(OVBox):
	def __init__(self):
		OVBox.__init__(self)
		self.signalHeader = None
	
	def process(self):
		for chunkIndex in range( len(self.input[0]) ):
			if(type(self.input[0][chunkIndex]) == OVSignalHeader):
				pass
				
			elif(type(self.input[0][chunkIndex]) == OVStreamedMatrixBuffer):
				chunk1 = 5*self.input[0].pop()
				chunk2 = 45*self.input[1].pop()
				F3 = chunk1[0]/chunk2[0]
				F4 = chunk1[1]/chunk2[1]
				print(F3,F4)
				print(F4-F3)
				#self.output[0].append(chunk)
				
			#elif(type(self.input[0][chunkIndex]) == OVSignalEnd):
			#	self.output[0].append(self.input[0].pop())	 			

box = MyOVBox()
