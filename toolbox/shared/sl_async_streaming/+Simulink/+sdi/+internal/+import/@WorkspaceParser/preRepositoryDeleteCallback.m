function preRepositoryDeleteCallback(this,~,evt)



    if strcmpi(evt.type,'signal')&&this.LazyImportParsers.isKey(evt.signalID)
        this.LazyImportParsers.deleteDataByKey(evt.signalID);
    elseif strcmpi(evt.type,'run')&&this.LazyImportRunIDs.isKey(evt.runID)
        sigIDs=Simulink.sdi.getRun(evt.runID).getAllSignalIDs();
        for idx=1:length(sigIDs)
            this.LazyImportParsers.deleteDataByKey(sigIDs(idx));
        end
        this.LazyImportRunIDs.deleteDataByKey(evt.runID);
    elseif strcmpi(evt.type,'all')
        this.LazyImportParsers.Clear();
        this.LazyImportRunIDs.Clear();
    end
end