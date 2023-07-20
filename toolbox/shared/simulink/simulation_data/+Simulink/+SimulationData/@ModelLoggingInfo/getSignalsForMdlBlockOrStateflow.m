function res=getSignalsForMdlBlockOrStateflow(this,...
    block,...
    bHonorDefaults,...
    bIncludeAllSigs,...
    okIfMdlBlkDoesNotExist)

































































    if nargin<5
        okIfMdlBlkDoesNotExist=false;
    end



    closeMdlObj=Simulink.SimulationData.ModelCloseUtil;%#ok<NASGU>


    if~isscalar(this)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoMethodNonScalar',...
        'getSignalsForMdlBlockOrStateflow');
    end


    if nargin<4||~ischar(block)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoInvalidGetInstanceArgs');
    end



    topModel=...
    Simulink.SimulationData.BlockPath.getModelNameForPath(block);
    if~strcmp(this.model_,topModel)
        this=this.updateModelName(topModel);
    end


    bIsStateflow=...
    Simulink.BlockPath.utIsStateflowChart(block);






    valid=bIsStateflow||...
    okIfMdlBlkDoesNotExist||...
    this.mdlBlockIsValidAndMayLog(block);

    if~valid
        res=Simulink.SimulationData.SignalLoggingInfo.empty;
        return;
    end


    [defSigs,bUseDefaults]=...
    getMdlBlockOrChartDefaultSignalsIfNeeded(this,...
    block,...
    bIsStateflow,...
    bIncludeAllSigs,...
    bHonorDefaults);
    if bUseDefaults
        res=defSigs;
        return;
    end


    res=this.getApplicableOverrideSignals(...
    block,...
    bIsStateflow);


    if bIncludeAllSigs
        res=this.addUniqueSignalsToVectorAndTurnOff(defSigs,res);
    end

end
