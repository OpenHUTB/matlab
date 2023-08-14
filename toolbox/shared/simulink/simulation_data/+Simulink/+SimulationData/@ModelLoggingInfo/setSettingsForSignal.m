function this=setSettingsForSignal(this,sig)









    bRemoveSig=~sig.loggingInfo_.dataLogging_;


    pos=this.findSignal(sig.blockPath_,sig.outputPortIndex_);


    if isempty(pos)
        if~bRemoveSig
            if isempty(this.signals_)
                this.signals_=sig;
            else
                this.signals_(end+1)=sig;
            end
        end


    elseif bRemoveSig
        assert(length(pos)==1);
        this=this.removeSignal(pos);


    else
        assert(length(pos)==1);
        this.signals_(pos).loggingInfo_=sig.loggingInfo_;
    end
end
