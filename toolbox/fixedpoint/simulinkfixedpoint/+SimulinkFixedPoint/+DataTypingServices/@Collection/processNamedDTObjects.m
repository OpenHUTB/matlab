function allResults=processNamedDTObjects(this,contextModel,runObject,sourceResults)








    allResults=getResultsAsCellArray(runObject);
    for iSource=1:numel(sourceResults)
        sourceResult=sourceResults{iSource};
        dTContainerInfo=sourceResult.getSpecifiedDTContainerInfo;

        [namedTypeResults]=createResults(this,contextModel,runObject,dTContainerInfo);


        allResults=[allResults,num2cell(namedTypeResults)];%#ok<AGROW>


        if isa(sourceResult,'fxptds.AbstractSimulinkObjectResult')
            sourceIDs=sourceResult.getActualSourceIDs;
        else
            sourceIDs={sourceResult.UniqueIdentifier};
        end


        for iResult=1:numel(namedTypeResults)
            SimulinkFixedPoint.Autoscaler.addToSrcList(runObject,namedTypeResults(iResult),sourceIDs);
        end

        sharedRecords=[namedTypeResults,sourceResult];


        for index=1:length(sharedRecords)-1
            runObject.dataTypeGroupInterface.addEdge(...
            sharedRecords(index).UniqueIdentifier.UniqueKey,...
            sharedRecords(index+1).UniqueIdentifier.UniqueKey);
        end
    end
end


