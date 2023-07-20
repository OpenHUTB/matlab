function postModelStartFromTop(modelH)




    try
        if~cvi.TopModelCov.isTopMostModel(modelH)
            return;
        end
        coveng=cvi.TopModelCov.getInstance(modelH);
        if isempty(coveng)
            return;
        end
        if~isempty(coveng.scriptDataMap)
            coveng.scriptStart(coveng.lastReportingModelH);
        end

        if isExternalEmlEnabled(coveng)
            modelcovIds=coveng.coderCov.modelStart;
            if~isempty(modelcovIds)
                coveng.addScriptModelcovId(coveng.lastReportingModelH,modelcovIds);
            end
        end
    catch MEx
        rethrow(MEx);
    end
end

function enableExternal=isExternalEmlEnabled(coveng)
    modelH=coveng.lastReportingModelH;
    enableExternal=false;
    if~isempty(modelH)&&(modelH>0)
        modelcovId=get_param(modelH,'CoverageId');
        if(modelcovId~=0)
            testId=cv('get',modelcovId,'.activeTest');
            if testId~=0
                cvt=cvtest(testId);
                enableExternal=cvt.emlSettings.enableExternal;
            end
        end
    end
end
