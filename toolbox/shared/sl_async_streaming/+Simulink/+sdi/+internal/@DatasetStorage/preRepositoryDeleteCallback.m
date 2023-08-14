function preRepositoryDeleteCallback(this,~,evt)







    if strcmpi(evt.type,'run')
        if evt.runID~=this.RunID
            return
        end
    elseif strcmpi(evt.type,'signal')
        repo=sdi.Repository(1);
        runID=repo.getSignalRunID(evt.signalID);
        if runID~=this.RunID
            return
        end
    end


    try
        fprintf(getString(message('SDI:sdi:ExportOnClearStart')));
        fullyLoadCache(this);
        fprintf(getString(message('SDI:sdi:ExportOnClearEnd')));
    catch
        Simulink.sdi.internal.warning(message('SDI:sdi:ExportOnClearWarning'));
    end
end