function[sigInfo,sigIdx,bSigNameChange,this]=...
    getSettingsForSignalUncached(this,...
    sigInfo,...
    sigIdx,...
    bSigNameChange,...
    bpath,...
    portIdx,...
    signalName)

    for idx=1:length(this.signals_)
        if this.signals_(idx).matchesSignal(bpath,portIdx)
            sigInfo=this.signals_(idx);
            sigIdx=uint32(idx);



            if~isempty(signalName)&&ischar(sigInfo.signalName_)
                if~strcmp(signalName,sigInfo.signalName_)


                    bSigNameChange=true;
                    old_name=this.signals_(idx).signalName_;
                    this.signals_(idx).signalName_=signalName;



                    if~this.signalIsInTopMdl(idx)
                        this.warnForRefSignalNameChange(...
                        idx,old_name);
                    end

                end
            end

            break;
        end
    end
end
