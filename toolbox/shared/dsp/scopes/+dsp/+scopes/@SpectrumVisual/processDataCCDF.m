function processDataCCDF(this,data)



    this.IsUpdateReady=true;

    resetDataBuffer(this);
    updateCCDF(this,data);
    this.IsNewDataReady=true;
    this.IsNewMeasurementsDataReady=true;
    updateCCDFPlot(this);

end
