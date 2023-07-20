function latencyInfo=getLatencyInfo(this,hC)


    if targetcodegen.targetCodeGenerationUtils.isNFPMode

        outputDelay=0;
    else

        slbh=hC.SimulinkHandle;
        iterNum=this.hdlslResolve('NumberOfIterations',slbh);
        outputDelay=iterNum+1;
    end

    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=outputDelay;
    latencyInfo.samplingChange=1;
end
