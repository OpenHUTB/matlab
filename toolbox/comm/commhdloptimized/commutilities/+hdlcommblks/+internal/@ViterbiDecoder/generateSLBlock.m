function generateSLBlock(this,hC,targetBlkPath)




    validBlk=1;

    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch me %#ok
        validBlk=0;
    end


    latencyInfo=this.getLatencyInfo(hC);

    if validBlk
        this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);
        [outputBlk,outputBlkPosition]=this.addSLBlockModel(hC,originalBlkPath,targetBlkPath);
        this.addSLBlockLatency(hC,targetBlkPath,latencyInfo,outputBlk,outputBlkPosition);
    end
