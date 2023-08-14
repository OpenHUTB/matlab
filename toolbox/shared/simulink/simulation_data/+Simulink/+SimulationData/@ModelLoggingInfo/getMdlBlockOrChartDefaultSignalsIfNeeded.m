function[defSigs,bUseDefaults]=...
    getMdlBlockOrChartDefaultSignalsIfNeeded(this,...
    block,...
    bIsStateflow,...
    bIncludeAllSigs,...
    bHonorDefaults)



























    bUseDefaults=false;
    defSigs=Simulink.SimulationData.SignalLoggingInfo.empty;


    if bIsStateflow



        if bIncludeAllSigs||...
            (bHonorDefaults&&this.getLogAsSpecifiedInModel(this.model_))
            defSigs=...
            Simulink.SimulationData.ModelLoggingInfo.getDefaultChartSignals(...
            Simulink.BlockPath,block,bIncludeAllSigs,defSigs);
            bUseDefaults=bHonorDefaults&&this.getLogAsSpecifiedInModel(this.model_);
        end



    elseif bIncludeAllSigs||...
        (bHonorDefaults&&this.getLogAsSpecifiedInModel(block))




        [mdl,bIncTestPoints]=...
        Simulink.SimulationData.ModelLoggingInfo.loadMdlForDefaultSignals(...
        block,this.model_,this);


        bp=Simulink.BlockPath(block);
        defSigs=Simulink.SimulationData.ModelLoggingInfo.getLoggedSignalsFromMdl(...
        mdl,...
        bp,...
        true,...
        'ActiveVariants',...
        'off',...
        'on',...
        'all',...
        true,...
        bIncludeAllSigs,...
        bIncTestPoints,...
        defSigs,...
        [],...
        this.model_);





        bUseDefaults=bHonorDefaults&&this.getLogAsSpecifiedInModel(block,false);
    end

end
