function out=refreshConfigSetHints(modelName,harnessName,workerId,workerRoot,tcId)



    if(nargin<4)
        workerId='';
        workerRoot='';
    elseif(nargin<5)
        tcId=0;
    end

    if(~isempty(workerId)&&~isempty(workerRoot))
        out=stm.internal.MRT.utility.queryModel(modelName,harnessName,...
        workerId,workerRoot,tcId,'configset');
    else
        out=stm.internal.MRT.share.refreshConfigSetHints(modelName,harnessName);
    end
end

