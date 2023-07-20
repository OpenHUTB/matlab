function[namedTypeResults]=createResults(this,contextModel,runObject,dTContainerInfo)










    [~,varSrcType,~]=dTContainerInfo.traceVar();
    namedTypeObject=dTContainerInfo.getResolvedObj;
    namedTypeObjectName=dTContainerInfo.origDTString;
    namedTypeWrapper=...
    SimulinkFixedPoint.NamedTypeObjectWrapperCreator.getWrapper(...
    namedTypeObject,namedTypeObjectName,contextModel.getFullName,varSrcType);


    data=struct('Object',namedTypeWrapper,'ElementName',namedTypeObjectName);
    dataHandler=fxptds.SimulinkDataArrayHandler;
    namedTypeResults=runObject.getResultByID(dataHandler.getUniqueIdentifier(data));


    if isempty(namedTypeResults)
        namedTypeResults=runObject.createAndUpdateResult(fxptds.SimulinkDataArrayHandler(data));
    end

    specifiedDTToSet=dTContainerInfo.evaluatedDTString;
    namedTypeResults.setSpecifiedDataType(specifiedDTToSet);

    isLastNode=isempty(dTContainerInfo.childDTContainerObj);

    if isLastNode

        namedTypeResults.SpecifiedDTContainerInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTToSet,[]);
    else


        namedTypeResults.SpecifiedDTContainerInfo=dTContainerInfo.childDTContainerObj;
        nextNamedTypeResult=createResults(this,contextModel,runObject,dTContainerInfo.childDTContainerObj);
        namedTypeResults=[namedTypeResults,nextNamedTypeResult];
    end
end


