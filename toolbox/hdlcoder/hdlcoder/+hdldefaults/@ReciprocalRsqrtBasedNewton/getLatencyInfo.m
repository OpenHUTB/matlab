function latencyInfo=getLatencyInfo(this,hC)











    if~hC.Synthetic
        iterNum=this.getChoice;
    else
        iterNum=hC.getIterNum;
    end


    hInSignals=hC.PirInputSignals;
    inputType=hInSignals.Type;
    inSigned=inputType.Signed;

    if inSigned
        outputDelay=iterNum+5;
    else
        outputDelay=iterNum+3;
    end


    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=outputDelay;
    latencyInfo.samplingChange=1;

end

