function setSyncMethodByRun(this,id,value)
    allIDs=this.getAllSignalIDs(id);
    for i=1:length(allIDs)
        this.sigRepository.setSignalSyncMethod(allIDs(i),value);
    end
end