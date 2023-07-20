function setInterpMethodByRun(this,id,value)
    allIDs=this.getAllSignalIDs(id);
    for i=1:length(allIDs)
        this.sigRepository.setSignalInterpMethod(allIDs(i),value);
        Simulink.sdi.WebClient.refreshInterpolation(allIDs(i));
    end
end