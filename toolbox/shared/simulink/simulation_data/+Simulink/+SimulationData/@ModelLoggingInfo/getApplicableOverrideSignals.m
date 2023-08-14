function res=getApplicableOverrideSignals(this,...
    block,...
    bIsStateflow)
























    if bIsStateflow
        minHierLen=1;
    else
        minHierLen=2;
    end

    res=Simulink.SimulationData.SignalLoggingInfo.empty;
    len=length(this.signals_);
    for idx=len:-1:1


        bHit=this.signals_(idx).blockPath_.getLength>=minHierLen&&...
        strcmp(this.signals_(idx).blockPath_.getBlock(1),block);


        if bHit
            res=[res,this.signals_(idx)];%#ok<AGROW>
        end

    end

end
