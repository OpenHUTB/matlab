function res=hasCumData(modelH)




    coveng=cvi.TopModelCov.getInstance(modelH);
    res=false;
    if~isempty(coveng)
        allModelcovIds=coveng.getAllModelcovIds;
        for currModelcovId=allModelcovIds(:)'
            if hasRunningTotal(currModelcovId);
                res=true;
                break;
            end
        end
    else
        modelcovId=get_param(modelH,'CoverageId');
        res=hasRunningTotal(modelcovId);
    end

    function res=hasRunningTotal(modelcovId)
        res=false;
        if modelcovId==0
            return;
        end
        rootId=cv('get',modelcovId,'.rootTree.child');
        if rootId==0
            return;
        end
        runningTotal=cv('get',rootId,'.runningTotal');
        res=~isempty(runningTotal)&&runningTotal~=0;

