function returnList=getModelParameters(modelName,harnessName,...
    workerId,workerRoot,tcId)





    if(nargin<4)
        workerId='';
        workerRoot='';
    elseif(nargin<5)
        tcId=0;
    end

    if(~isempty(workerId)&&~isempty(workerRoot))
        returnList=stm.internal.MRT.utility.queryModel(modelName,harnessName,...
        workerId,workerRoot,tcId,'parameter');
    else
        returnList=stm.internal.MRT.share.getModelParameters(modelName,harnessName);
    end
end
