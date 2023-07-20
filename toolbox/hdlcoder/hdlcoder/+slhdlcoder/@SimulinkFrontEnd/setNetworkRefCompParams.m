function setNetworkRefCompParams(this,thisNetwork,configManager,...
    blockPath,checkSampleTime)


    if this.HDLCoder.nonTopDut&&~contains(blockPath,'/')




        checkSampleTime=false;
        origBlockPath=this.HDLCoder.OrigStartNodeName;
        locConfigMgr=this.HDLCoder.getConfigManager(this.HDLCoder.OrigModelName);
        subsysImplParams=locConfigMgr.getSubsystemImplementationParams(origBlockPath);
    else
        subsysImplParams=configManager.getSubsystemImplementationParams(blockPath);
    end

    numImplParams=length(subsysImplParams);
    if~isempty(subsysImplParams)
        for i=1:2:numImplParams
            [msgobj,level]=slhdlcoder.SimulinkFrontEnd.validateAndSetNetworkParam(...
            subsysImplParams(i:i+1),blockPath,thisNetwork,checkSampleTime);
            if~isempty(msgobj)
                this.updateChecks(blockPath,'block',msgobj,level);
            end
        end
    end
end


