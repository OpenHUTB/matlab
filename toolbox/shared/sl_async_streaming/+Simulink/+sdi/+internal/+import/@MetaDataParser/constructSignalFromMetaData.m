function sig=constructSignalFromMetaData(this,sigIdx)



    sig=Simulink.SimulationData.Signal;
    sig.PortType='outport';


    sig.Name=this.ParsedValues(sigIdx).Name;
    if~isempty(this.ParsedValues(sigIdx).BlockPath)
        sig.BlockPath=this.ParsedValues(sigIdx).BlockPath;
    end
    if~isempty(this.ParsedValues(sigIdx).PortIndex)
        val=str2double(this.ParsedValues(sigIdx).PortIndex);
        if~isnan(val)&&val>0
            sig.PortIndex=val;
        end
        this.ParsedValues(sigIdx).OverridePortIndex=false;




    else
        this.ParsedValues(sigIdx).OverridePortIndex=true;
    end


    sigTs=timeseries.utcreatewithoutcheck(0,0,false,false);

    if~isempty(this.ParsedValues(sigIdx).CustomName)
        sigTs.Name=this.ParsedValues(sigIdx).CustomName;
    else
        sigTs.Name=sig.Name;
    end
    sig.Values=sigTs;
    if~isempty(this.ParsedValues(sigIdx).Unit)
        sig.Values.DataInfo.Units=this.ParsedValues(sigIdx).Unit;
    end
    if~isempty(this.ParsedValues(sigIdx).Interp)
        sig.Values.DataInfo.Interpolation=this.ParsedValues(sigIdx).Interp;
    else
        sig.Values.DataInfo.Interpolation='zoh';
    end


    sig=sig.setVisualizationMetadata(this.ParsedValues(sigIdx));
end