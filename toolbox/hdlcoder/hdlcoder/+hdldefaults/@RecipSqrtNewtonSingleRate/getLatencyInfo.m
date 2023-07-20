function latencyInfo=getLatencyInfo(~,hC)



    if~hC.Synthetic
        slbh=hC.SimulinkHandle;
    else
        slbh=get_param([hC.Owner.FullPath,'/',hC.Name],'handle');
    end

    iterNum=hdlslResolve('Iterations',slbh);

    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=iterNum*4+5;
    latencyInfo.samplingChange=1;
end
