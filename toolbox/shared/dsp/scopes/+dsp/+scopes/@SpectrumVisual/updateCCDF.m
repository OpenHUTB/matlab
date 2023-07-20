function updateCCDF(this,data)






    [m,n,p]=size(data);
    data=reshape(data,m*n,p);

    data=data.*conj(data);

    [maxPow,avgPow,totSamps,dist]=updateCCDF(this.DataBuffer,data,...
    this.NumCCDFHistogramBins,this.CCDFPowerResolutionInDB);

    this.CurrentCCDFMaxPower=10*log10(maxPow./this.pReferenceLoad);
    this.CurrentCCDFAvgPower=10*log10(avgPow./this.pReferenceLoad);
    this.CurrentCCDFSampleCount=totSamps;
    this.CurrentCCDFDistribution=dist;
end
