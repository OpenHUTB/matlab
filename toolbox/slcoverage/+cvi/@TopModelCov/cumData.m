function cumData(modelH,cmd,cvd)




    coveng=cvi.TopModelCov.getInstance(modelH);
    if strcmpi(cmd,'set')
        if~isempty(coveng)
            allModelcovIds=coveng.getAllModelcovIds;
            for currModelcovId=allModelcovIds(:)'
                mn=SlCov.CoverageAPI.getModelcovName(currModelcovId);
                setRunningTotal(currModelcovId,cvd.get(mn));
            end
        else
            modelcovId=get_param(modelH,'CoverageId');
            setRunningTotal(modelcovId,cvd)
        end

    elseif strcmpi(cmd,'reset')

        if~isempty(coveng)
            allModelcovIds=coveng.getAllModelcovIds;
            for currModelcovId=allModelcovIds(:)'
                resetRunningTotal(currModelcovId);
            end
        else
            modelcovId=get_param(modelH,'CoverageId');
            resetRunningTotal(modelcovId)
        end
    end

    function setRunningTotal(modelcovId,cvd)
        if~isempty(cvd)
            rootId=cv('get',modelcovId,'.rootTree.child');
            cv('set',rootId,'.runningTotal',cvd.id);
        end


        function resetRunningTotal(modelcovId)

            rootId=cv('get',modelcovId,'.rootTree.child');
            cv('set',rootId,'.runningTotal',[]);
            cv('set',rootId,'.prevRunningTotal',[]);
