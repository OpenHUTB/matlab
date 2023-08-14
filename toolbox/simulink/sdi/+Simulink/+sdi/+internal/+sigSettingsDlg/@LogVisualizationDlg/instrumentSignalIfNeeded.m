function instrumentSignalIfNeeded(this)




    if~isempty(this.SigInfo)
        sig.OutputPortIndex=get(this.SigInfo.portH,'PortNumber');
        sig.BlockPath=Simulink.BlockPath(get_param(this.SigInfo.portH,'Parent'));
        Simulink.sdi.internal.ObserverInterface.instrumentModel(sig);
    end
end
