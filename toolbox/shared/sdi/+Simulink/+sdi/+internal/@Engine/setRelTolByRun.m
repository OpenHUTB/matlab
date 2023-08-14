function setRelTolByRun(this,id,value)
    allIDs=this.getAllSignalIDs(id);
    for i=1:length(allIDs)
        this.sigRepository.setSignalRelTol(allIDs(i),value);
    end
end