function latencyInfo=getLatencyInfo(this,hC)











    if~hC.Synthetic
        iterNum=this.getChoice;
    else
        iterNum=hC.getIterNum;
    end


    outputDelay=iterNum+3;


    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=outputDelay;
    latencyInfo.samplingChange=1;

