function lastRun=getLastSDIRunForModel(modelName)



    lastRun=[];
    repository=sdi.Repository(true);
    runIDs=repository.getAllRunIDs;
    qualifiedRuns={};
    for i=1:numel(runIDs)
        thisRunID=runIDs(i);
        thisRun=Simulink.sdi.getRun(thisRunID);
        if isequal(thisRun.Model,modelName)
            qualifiedRuns{end+1}=thisRun;%#ok<AGROW> 
        end
    end
    if numel(qualifiedRuns)>0
        lastRun=qualifiedRuns{1};
        for i=2:numel(qualifiedRuns)
            if qualifiedRuns{i}.DateCreated>lastRun.DateCreated
                lastRun=qualifiedRuns{i};
            end
        end
    end
end