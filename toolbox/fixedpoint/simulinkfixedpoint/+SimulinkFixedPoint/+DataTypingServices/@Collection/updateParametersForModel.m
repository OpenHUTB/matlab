function updateParametersForModel(this,currentModel)




    compileHandler=startCompile(this,currentModel);
    appData=SimulinkFixedPoint.getApplicationData(currentModel);
    runObj=appData.dataset.getRun(this.proposalSettings.scaleUsingRunName);
    allResults=runObj.getResultsAsCellArray;
    for rIndex=1:numel(allResults)
        currentResult=allResults{rIndex};
        blockObject=currentResult.UniqueIdentifier.getObject;
        if~isempty(blockObject)&&~isa(blockObject,'Simulink.Parameter')



            params=currentResult.getAutoscaler.gatherAssociatedParam(blockObject);
            this.setAssociatedParam(params,runObj);
        end
    end

    pObjInfoCollector=SimulinkFixedPoint.ParameterObjectInfoCollector(currentModel);
    pObjInfoList=pObjInfoCollector.getParameterObjectInfo;
    for pIndex=1:length(pObjInfoList)
        pObjInfo=pObjInfoList{pIndex};
        [result,isNew,parameterObjectWrapper]=createParameterResult(this,currentModel,pObjInfo,runObj);
        assert(~isNew);
        updateParameterModelRequiredRanges(this,parameterObjectWrapper,pObjInfo,result);

    end

    stopCompile(this,compileHandler);

end