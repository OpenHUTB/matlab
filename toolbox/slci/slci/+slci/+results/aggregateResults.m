

function aggregateResults(datamgr,reportConfig,slciConfig)



    resultTableReader=datamgr.getReader('RESULTS');




    blockReader=datamgr.getReader('BLOCK');

    modelStatus=aggregateTable(blockReader,reportConfig,slciConfig);
    modelStatus=reportConfig.getTopVerStatus(modelStatus);
    resultTableReader.replaceObject('ModelInspectionStatus',modelStatus);




    functionInterfaceReader=datamgr.getReader('FUNCTIONINTERFACE');

    functionInterfaceStatus=aggregateTable(functionInterfaceReader,reportConfig,slciConfig);
    resultTableReader.replaceObject('InterfaceInspectionStatus',functionInterfaceStatus);


    functionBodyReader=datamgr.getReader('FUNCTIONBODY');
    aggCodeStatus=reportConfig.defaultStatus;
    aggTempVarStatus=reportConfig.defaultStatus;




    functionInterfaceKeys=functionInterfaceReader.getKeys();
    numFunctionInterface=numel(functionInterfaceKeys);
    for k=1:numFunctionInterface

        func=functionInterfaceKeys{k};
        if functionBodyReader.hasObject(func)
            funcBody=functionBodyReader.getObject(func);
            thisCodeStatus=funcBody.getCodeStatus();
            thisTempVarStatus=funcBody.getTempVarStatus();
        else


            funcInterfaceObject=functionInterfaceReader.getObject(func);
            thisCodeStatus=funcInterfaceObject.getStatus();
            thisTempVarStatus=funcInterfaceObject.getStatus();
        end
        aggCodeStatus=reportConfig.getHeaviestStatus(aggCodeStatus,...
        thisCodeStatus);
        aggTempVarStatus=reportConfig.getHeaviestStatus(aggTempVarStatus,...
        thisTempVarStatus);
    end
    resultTableReader.replaceObject('CodeInspectionStatus',aggCodeStatus);
    resultTableReader.replaceObject('TempVarInspectionStatus',aggTempVarStatus);


    typeReplacementReader=datamgr.getReader('TYPEREPLACEMENT');

    typeReplacementStatus=aggregateTable(typeReplacementReader,reportConfig,slciConfig);
    resultTableReader.replaceObject('TypeReplacementStatus',typeReplacementStatus);


    verificationStatus=reportConfig.getHeaviestStatus(modelStatus,...
    aggCodeStatus,...
    aggTempVarStatus,...
    typeReplacementStatus,...
    functionInterfaceStatus);

    resultTableReader.replaceObject('VerificationStatus',verificationStatus);


    codeTraceStatus=slci.results.aggregateCodeTrace(datamgr,reportConfig);
    resultTableReader.replaceObject('CodeTraceabilityStatus',codeTraceStatus);



    modelTraceStatus=slci.results.aggregateModelTrace(datamgr,reportConfig,slciConfig);
    resultTableReader.replaceObject('ModelTraceabilityStatus',modelTraceStatus);


    traceStatus=reportConfig.getHeaviestStatus(codeTraceStatus,modelTraceStatus);
    resultTableReader.replaceObject('TraceabilityStatus',traceStatus);


    functionCallReader=datamgr.getReader('FUNCTIONCALL');

    utilsStatus=aggregateTable(functionCallReader,reportConfig,slciConfig);
    resultTableReader.replaceObject('UtilsStatus',utilsStatus);

end

function aggStatus=aggregateTable(reader,reportConfig,slciConfig)


    aggStatus=reportConfig.defaultStatus;
    ObjectKeys=reader.getKeys();
    Objects=reader.getObjects(ObjectKeys);
    numObjects=numel(Objects);


    modelManager=slciConfig.getModelManager();
    for k=1:numObjects
        thisObject=Objects{k};


        if isa(thisObject,'slci.results.HiddenBlockObject')&&slcifeature('SLCIJustification')==1
            if~isempty(modelManager)&&modelManager.isFiltered(thisObject.fOrigBlock)

                thisObject.setStatus('JUSTIFIED');
            end
        end
        aggStatus=reportConfig.getHeaviestStatus(thisObject.getStatus(),...
        aggStatus);
    end
end
