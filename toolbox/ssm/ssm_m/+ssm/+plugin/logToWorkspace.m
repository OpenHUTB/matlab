


function ds=logToWorkspace(runID,dataTableName,writerNames,hierarchicalNames)

    sdiRun=Simulink.sdi.getRun(runID);
    ds=getSetDataStoreStruct(runID);


    dataTableNameVar=genvarname(dataTableName);


    ds.(dataTableNameVar)=struct;

    for j=1:length(writerNames)

        writerNameVar=genvarname(writerNames{j});


        ds.(dataTableNameVar).(writerNameVar)=Simulink.SimulationData.Dataset;

        for k=1:length(hierarchicalNames)

            signalName=[dataTableName,'.',writerNames{j},'.',hierarchicalNames{k}];


            hierarchicalNameVar=genvarname(hierarchicalNames{k});

            signalID=getSignalIDsByName(sdiRun,signalName);
            signal=Simulink.sdi.getSignal(signalID);
            signal=convertSDISignalToSimulationDataSignal(signal,hierarchicalNameVar);

            idx=ds.(dataTableNameVar).(writerNameVar).numElements+1;
            ds.(dataTableNameVar).(writerNameVar){idx}=signal;
        end
    end

    ds=getSetDataStoreStruct(runID,ds);

end





function ret=getSetDataStoreStruct(runID,varargin)
    persistent ds curRunID


    if isempty(curRunID)||runID~=curRunID
        curRunID=runID;
        ds=struct;
    end

    if~isempty(varargin)
        ds=varargin{1};
    end

    ret=ds;
end





function ret=convertSDISignalToSimulationDataSignal(signal,logSignalName)
    ret=Simulink.SimulationData.Signal;
    ret.Name=logSignalName;
    ret.PropagatedName='';
    ret.BlockPath=Simulink.SimulationData.BlockPath(signal.BlockPath);
    ret.PortType='outport';
    ret.PortIndex=signal.PortIndex;
    ret.Values=signal.Values;
end