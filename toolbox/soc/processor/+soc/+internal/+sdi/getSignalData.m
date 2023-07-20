function sigData=getSignalData(runID,sigName)




    narginchk(2,2);
    nargoutchk(0,1);

    repository=sdi.Repository(true);
    sigIDs=repository.getAllSignalIDs(runID);
    sigNames=soc.internal.sdi.getSignalNames(runID);
    index=strmatch(sigName,sigNames,'exact');%#ok<MATCH3>
    assert(~isempty(index),['SDI does not contain the signal: ',sigName]);
    sigData=repository.getSignalDataValues(sigIDs(index));
end