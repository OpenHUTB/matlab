function resetCCDF(this)




    this.CurrentCCDFAvgPower=[];
    this.CurrentCCDFMaxPower=[];
    this.CurrentCCDFSampleCount=[];
    if~isempty(this.DataBuffer)&&isvalid(this.DataBuffer)
        resetCCDF(this.DataBuffer);
    end


    if isCCDFMode(this)
        resetDataBuffer(this);
    end
end
