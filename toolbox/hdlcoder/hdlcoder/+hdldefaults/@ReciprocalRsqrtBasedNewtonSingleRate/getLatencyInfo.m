function latencyInfo=getLatencyInfo(this,hC)











    iterNum=this.getChoice;


    hInSignals=hC.PirInputSignals;
    inputType=hInSignals.Type;
    inSigned=inputType.Signed;

    if inSigned
        outputDelay=iterNum*4+8;
    else
        outputDelay=iterNum*4+6;
    end



    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=outputDelay;
    latencyInfo.samplingChange=1;

end

