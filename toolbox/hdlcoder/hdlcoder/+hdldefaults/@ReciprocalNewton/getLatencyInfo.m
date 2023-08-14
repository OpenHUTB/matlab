function latencyInfo=getLatencyInfo(this,hC)











    if~hC.Synthetic
        newtonInfo=this.getBlockInfo(hC);
        iterNum=newtonInfo.iterNum;
    else
        iterNum=hC.getIterNum;
    end

    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=1+iterNum;
    latencyInfo.samplingChange=1;

end

