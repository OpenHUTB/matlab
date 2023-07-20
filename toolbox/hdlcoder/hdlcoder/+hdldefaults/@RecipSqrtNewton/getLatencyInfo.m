function latencyInfo=getLatencyInfo(~,hC)



    if~hC.Synthetic
        slbh=hC.SimulinkHandle;
        iterNum=hdlslResolve('Iterations',slbh);
    else
        iterNum=hC.getIterNum;
    end


    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=iterNum+2;
    latencyInfo.samplingChange=1;
end
