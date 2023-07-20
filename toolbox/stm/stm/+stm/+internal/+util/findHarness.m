function harnessStructArr=findHarness(modelName,workerId,workerRoot,tcId,fromRefreshAll)



    if(nargin<3)
        workerId='';
        workerRoot='';
    elseif(nargin<4)
        tcId=0;
    end

    if(~isempty(workerId)&&~isempty(workerRoot))
        suppressError=true;
        if(nargin==5)
            suppressError=fromRefreshAll;
        end
        harnessStructArr=stm.internal.MRT.utility.queryModel(modelName,'',...
        workerId,workerRoot,tcId,'harness',suppressError);
    else
        harnessStructArr=stm.internal.MRT.share.findHarness(modelName);
    end
end
