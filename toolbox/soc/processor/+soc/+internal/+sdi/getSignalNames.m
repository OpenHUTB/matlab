function sigNames=getSignalNames(runID)




    narginchk(1,1);
    nargoutchk(0,1);
    repository=sdi.Repository(true);
    sigIDs=repository.getAllSignalIDs(runID);
    sigNames=arrayfun(@(x)repository.getSignalLabel(x),sigIDs,...
    'UniformOutput',false);
end
