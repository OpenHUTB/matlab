function writeExecutionOutput(outputInfoStruct)







    rt=sfroot;
    machine=rt.find('-isa','Stateflow.Machine','Name',outputInfoStruct.ObserverModel);
    machineId=machine.Id;
    chartHandle=machine.find('-isa','Stateflow.Chart','Name',outputInfoStruct.SequenceDiagram);
    instanceH=get_param(chartHandle.Path,'Handle');


    warningsDataH=chartHandle.find('-isa','Stateflow.Data','Name',outputInfoStruct.WarningPort);
    warningsDataID=warningsDataH.Id;
    warningsDataName=warningsDataH.Name;


    verdictDataH=chartHandle.find('-isa','Stateflow.Data','Name',outputInfoStruct.VerdictPort);
    verdictDataID=verdictDataH.Id;
    verdictDataName=verdictDataH.Name;


    dataSymbolValues=sfprivate('getDataValueFromMexFunction',machineId,{verdictDataName,warningsDataName},[verdictDataID,warningsDataID],instanceH);









    simOutStruct=struct(...
    'Name',outputInfoStruct.SequenceDiagram,...
    'Completed',logical(dataSymbolValues{1}),...
    'NumErrors',dataSymbolValues{2}...
    );
    sdOutFieldName='seqOut';
    if~isempty(get_param(outputInfoStruct.ArchitectureModel,'ObservedSequenceDiagramsOut'))
        sdOutFieldName=genvarname(get_param(outputInfoStruct.ArchitectureModel,'ObservedSequenceDiagramsOut'));
    end

    bdObj=get_param(outputInfoStruct.ArchitectureModel,'Object');
    bdObj.addVarToSimulationOutput(sdOutFieldName,'SequenceDiagramExecution',simOutStruct);

end
