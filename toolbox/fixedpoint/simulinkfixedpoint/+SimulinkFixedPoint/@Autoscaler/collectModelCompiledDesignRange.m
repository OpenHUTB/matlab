function collectModelCompiledDesignRange(subsysObj,selectedRunName)






    mdl=SimulinkFixedPoint.AutoscalerUtils.getModelForAutoscaling(subsysObj);

    mdlRefTargetType=get_param(mdl,'ModelReferenceTargetType');
    targetName=slprivate('perf_logger_target_resolution',mdlRefTargetType,mdl,false,false);

    PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    mdl,...
    targetName,...
    'Collect Model Compiled Design Range',...
    true);

    cleanupObjOuter=onCleanup(@()PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    mdl,...
    targetName,...
    'Collect Model Compiled Design Range',...
    false));

    appData=SimulinkFixedPoint.getApplicationData(mdl);
    appData.ScaleUsing=selectedRunName;

    errorID='';

    mh=compileModel(mdl,targetName);

    errorID=removeRunResults(appData,mdl,errorID,targetName);
    errorID=termModel(mdl,errorID,targetName,mh);

    if~isempty(errorID)
        throw(errorID)
    end
end


function mh=compileModel(mdl,targetName)

    PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    mdl,...
    targetName,...
    'Compile Model',...
    true);

    cleanupObjOuter=onCleanup(@()PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    mdl,...
    targetName,...
    'Compile Model',...
    false));

    mh=fixed.internal.modelcompilehandler.ModelCompileHandler(mdl);
    mh.start();
end


function errorID=removeRunResults(appData,mdl,prevErrorID,targetName)

    PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    mdl,...
    targetName,...
    'Remove Run Results',...
    true);

    cleanupObjOuter=onCleanup(@()PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    mdl,...
    targetName,...
    'Remove Run Results',...
    false));

    errorID=prevErrorID;
    try
        runObj=appData.dataset.getRun(appData.ScaleUsing);
        resultsToRemove=updateAllResults(runObj);
        for i=1:length(resultsToRemove)
            if resultsToRemove(i).isResultValid
                runObj.clearResultFromRun(resultsToRemove(i));
            end
        end

        if appData.subDatasetMap.Count>0
            keys=appData.subDatasetMap.keys;
            for idx=1:length(keys)
                curDS=appData.subDatasetMap(keys{idx});
                runObj=curDS.getRun(appData.ScaleUsing);
                updateAllResults(runObj);
            end
        end
    catch eDesignFail
        errorID=eDesignFail;
    end
end


function errorID=termModel(mdl,prevErrorID,targetName,mh)

    PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    mdl,...
    targetName,...
    'Term Model',...
    true);

    cleanupObjOuter=onCleanup(@()PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    mdl,...
    targetName,...
    'Term Model',...
    false));

    errorID=prevErrorID;
    try
        mh.stop();
    catch engineTermFail

        if~isempty(errorID)
            errorID=engineTermFail;
        end
    end
end


function resultsToRemove=updateAllResults(runObj)


    results=runObj.getResults;


    nResults=numel(results);



    removeResultFlag=zeros(1,nResults);


    for iResult=1:nResults
        removeResultFlag(iResult)=updateResult(results(iResult));
    end


    resultsToRemove=results(logical(removeResultFlag));

end

function removeResult=updateResult(result)

    if result.isResultValid
        [dStruct.CompiledDesignMin,dStruct.CompiledDesignMax,dStruct.CompiledDT,removeResult]=...
        result.getAutoscaler.getModelCompiledDesignRange(result.UniqueIdentifier.getObject,result.UniqueIdentifier.getElementName);

        [dStruct.DesignMin,dStruct.DesignMax]=result.getAutoscaler.gatherDesignMinMax(result.UniqueIdentifier.getObject,result.UniqueIdentifier.getElementName);

        result.updateResultData(dStruct);

    else
        removeResult=true;
    end
end




