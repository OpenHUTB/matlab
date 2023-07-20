function generateSLBlock(this,hC,targetBlkPath)





















    validBlk=1;

    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch
        validBlk=0;
    end

    if validBlk
        lat=hC.getImplementationLatency;
        if~isempty(lat)&&lat>0
            generateSLBlockWithDelay(this,hC,originalBlkPath,targetBlkPath,lat);
        elseif hC.getIsProtectedModel
            generateSLProtectedModel(this,hC,originalBlkPath,targetBlkPath);
        else
            targetBlkPath=addSLBlock(this,hC,originalBlkPath,targetBlkPath);
        end
    else

    end
