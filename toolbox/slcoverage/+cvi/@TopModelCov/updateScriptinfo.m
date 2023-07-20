



function updateScriptinfo(coveng,testId,handle,cvScriptId)
    if testId==0||isempty(coveng.scriptDataMap)
        return;
    end

    data=coveng.scriptDataMap([coveng.scriptDataMap.cvScriptId]==cvScriptId);
    info=dir(data.scriptPath);
    if isempty(info)



        fpath=which(data.scriptName);
        info=dir(fpath);
    end
    cv('set',testId,'.lastModifiedDate',info.date);
    cvi.TopModelCov.updateSimulationOptimizationOptions(testId,handle);
end
