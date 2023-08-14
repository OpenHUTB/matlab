function[groupnames,blockName,description]=refreshSigBuilderHints(...
    modelName,harnessName,workerId,workerRoot,tcId)





    if(nargin<4)
        workerId='';
        workerRoot='';
    elseif(nargin<5)
        tcId=0;
    end

    if(~isempty(workerId)&&~isempty(workerRoot))
        out=stm.internal.MRT.utility.queryModel(modelName,harnessName,...
        workerId,workerRoot,tcId,'signalbuildergroup');
    else
        out=stm.internal.MRT.share.refreshSigBuilderHints(modelName,harnessName);
    end
    groupnames=out.groupnames;
    blockName=out.blockName;
    description=out.description;
end
