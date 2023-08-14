function latencyInfo=getLatencyInfo(this,hC)











    if~hC.Synthetic
        newtonInfo=this.getBlockInfo(hC);
        iterNum=newtonInfo.iterNum;
    else
        iterNum=hC.getIterNum;
    end

    latencyInfo.inputDelay=0;
    if~hC.PirInputSignals(1).Type.BaseType.isFloatType
        latencyInfo.outputDelay=1+(iterNum*2);
        latencyInfo.samplingChange=1;
    else

        latencyInfo.outputDelay=0;
        latencyInfo.samplingChange=0;
    end

end

