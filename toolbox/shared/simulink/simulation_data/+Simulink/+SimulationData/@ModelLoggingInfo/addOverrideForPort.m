function[this,bChanged]=addOverrideForPort(this,bpath,portIdx)







    bChanged=false;


    if this.getLogAsSpecifiedInModel(this.model_)
        return;
    end


    if~isempty(this.findSignal(bpath,portIdx))
        return;
    end



    sig=Simulink.SimulationData.SignalLoggingInfo;
    sig.BlockPath=bpath;
    sig.OutputPortIndex=portIdx;
    sig=sig.updateSettingsFromPort(true);

    if isempty(this.signals_)
        this.signals_=sig;
    else
        this.signals_(end+1)=sig;
    end

    bChanged=true;

end
