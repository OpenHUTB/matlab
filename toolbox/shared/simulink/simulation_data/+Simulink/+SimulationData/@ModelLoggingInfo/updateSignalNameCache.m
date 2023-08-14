function[sig,this]=updateSignalNameCache(this,sigIdx)






    old_name=this.signals_(sigIdx).signalName_;
    this.signals_(sigIdx).signalName_=...
    this.signals_(sigIdx).getSignalNameFromPort(false);
    sig=this.signals_(sigIdx);



    if ischar(old_name)&&~strcmp(old_name,sig.signalName_)&&...
        ~this.signalIsInTopMdl(sigIdx)
        set_param(this.model_,'DataLoggingOverride',this);
        this.warnForRefSignalNameChange(sigIdx,old_name);
    end

end
