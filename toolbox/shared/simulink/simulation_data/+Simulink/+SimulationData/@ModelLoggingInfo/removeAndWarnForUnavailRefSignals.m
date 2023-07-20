function this=removeAndWarnForUnavailRefSignals(this,idxToRemove)





    removeSigStr=sprintf('\n\n');
    bLoggedSignalRemoved=false;
    for idx=1:length(idxToRemove)
        sig_idx=idxToRemove(idx);
        if this.signals_(sig_idx).loggingInfo_.dataLogging_
            bLoggedSignalRemoved=true;
            curSigStr=evalc('display(this.signals_(sig_idx),true);');
            removeSigStr=sprintf('%s%s',removeSigStr,curSigStr);
        end
    end







    if bLoggedSignalRemoved
        DAStudio.warning(...
        'Simulink:Logging:RefMdlOverrideUpdated',...
        this.model_,...
        removeSigStr);
    else
        DAStudio.warning(...
        'Simulink:Logging:TopMdlOverrideUpdated',...
        this.model_);
    end


    this=this.removeSignals_(idxToRemove);

end
