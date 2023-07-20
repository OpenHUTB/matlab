function DataBuffer=getDataBuffer(this,~,rate,maxNumTimeSteps,maxDimensions,isInputComplex)




    setupBufferParams(this.DataBuffer,1,rate,maxNumTimeSteps(1),maxDimensions(1,:),isInputComplex(1));
    DataBuffer=this.DataBuffer;
end
