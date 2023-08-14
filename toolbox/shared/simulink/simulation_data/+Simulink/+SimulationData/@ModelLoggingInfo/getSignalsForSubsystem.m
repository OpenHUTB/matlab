function[bLogAsSpec,res]=getSignalsForSubsystem(this,bp)





















    res=Simulink.SimulationData.SignalLoggingInfo.empty;
    bLogAsSpec=true;
    if bp.getLength()<1||isempty(bp.getBlock(1))
        return;
    end


    fullPath=bp.convertToCell;
    mdlBlk=Simulink.BlockPath(fullPath(1:end-1));
    ssPath=fullPath{end};


    bIncTestPoints=this.supportsTestPointSignals();


    res=Simulink.SimulationData.ModelLoggingInfo.getLoggedSignalsFromMdl(...
    ssPath,...
    mdlBlk,...
    false,...
    'ActiveVariants',...
    'off',...
    'on',...
    'all',...
    false,...
    bIncTestPoints,...
    bIncTestPoints,...
    res,...
    bp.SubPath,...
    this.model_,...
    true);


    bLogAsSpec=this.getLogAsSpecifiedInModel(bp.getBlock(1),false);
    if bLogAsSpec
        return
    end


    for idx=1:length(res)
        [bDef,override]=this.getSettingsForSignal(...
        res(idx).BlockPath.convertToCell(),...
        res(idx).OutputPortIndex,...
        res(idx).BlockPath.SubPath,...
        false,...
        '',...
        false);

        if~bDef
            if isempty(override)
                res(idx).LoggingInfo.DataLogging=false;
            else
                res(idx)=override;
            end
        end
    end

end
