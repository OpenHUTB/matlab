function setAbsTolByRun(this,id,value)
    allIDs=this.getAllSignalIDs(id);
    for i=1:length(allIDs)
        this.sigRepository.setSignalAbsTol(allIDs(i),value);
    end
end