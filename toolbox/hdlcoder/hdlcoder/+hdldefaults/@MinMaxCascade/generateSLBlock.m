function generateSLBlock(this,hC,targetBlkPath)






    reporterrors(this,hC);

    validBlk=1;

    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch
        validBlk=0;
    end

    latencyInfo=this.getLatencyInfo(hC);

    if validBlk
        targetBlkPath=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);
        [outputBlk,outputBlkPosition]=this.addSLBlockModel(hC,originalBlkPath,targetBlkPath);
        this.addSLBlockLatency(hC,targetBlkPath,latencyInfo,outputBlk,outputBlkPosition);
    end
