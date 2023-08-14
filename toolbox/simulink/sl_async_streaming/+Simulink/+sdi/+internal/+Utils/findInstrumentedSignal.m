


function sigID=findInstrumentedSignal(mdl,sigInfo)


    sigID='';
    sigs=get_param(mdl,'InstrumentedSignals');
    if~isempty(sigs)
        import Simulink.sdi.internal.ObserverInterface;
        idx=ObserverInterface.getInstrumentedSignalIdx(sigInfo,sigs);
        if idx~=0
            sig=get(sigs,idx);
            sigID=sig.UUID;
        end
    end

end
