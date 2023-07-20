function setInstrumentedSignal(this,sig,index)



    sigs=get_param(this.SigInfo.mdl,'InstrumentedSignals');
    sigs.set(index,sig);
    set_param(this.SigInfo.mdl,'InstrumentedSignals',sigs);
end
