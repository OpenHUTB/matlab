function scale_collect(this,sudObject,modelName,runObj)






    compileHandler=startCompile(this,modelName);%#ok<NASGU>

    errorID=MException.empty();
    try




        this.discoverResults(runObj,sudObject,modelName);

        allResults=runObj.getResultsAsCellArray;

        namedDTDetectionUtil=SimulinkFixedPoint.NamedDTDetectionUtil;
        for iResult=1:numel(allResults)
            currentResult=allResults{iResult};
            currentObject=currentResult.UniqueIdentifier.getObject;
            if~(isa(currentObject,'Simulink.SubSystem')||isa(currentObject,'Simulink.Parameter'))
                currentElementName=currentResult.UniqueIdentifier.getElementName;
                currentAutoscaler=currentResult.getAutoscaler;
                dtContainer=currentResult.getSpecifiedDTContainerInfo();
                if isempty(dtContainer)||dtContainer.isUnknown()
                    currentResult.SpecifiedDTContainerInfo=currentAutoscaler.gatherSpecifiedDT(currentObject,currentElementName);
                end
                namedDTDetectionUtil.detectAndAddToNamedDTList(currentResult);
            end
        end


        paramResults=this.processParameterObjects(modelName,runObj);
        for rIndex=1:length(paramResults)
            namedDTDetectionUtil.detectAndAddToNamedDTList(paramResults{rIndex});
        end




        resultsClientOfNamedType=getListOfResults(namedDTDetectionUtil);
        processNamedDTObjects(this,get_param(modelName,'Object'),runObj,resultsClientOfNamedType);
    catch eCollectFail


        errorID=eCollectFail;
    end




    runObj.deleteInvalidResults();




    if~isempty(errorID)
        throw(errorID);
    end
end

