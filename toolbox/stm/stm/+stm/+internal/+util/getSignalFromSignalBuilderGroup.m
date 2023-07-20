

function runId=getSignalFromSignalBuilderGroup(blockName,groupName,fileName)

    [~,~,sigNames]=signalbuilder(blockName);
    numberOfSignals=length(sigNames);
    dataSets=Simulink.SimulationData.Dataset;

    for sigId=1:numberOfSignals
        [time,data]=signalbuilder(blockName,'get',sigNames{sigId},groupName);
        ts=timeseries(data,time);
        dataSets=addElement(dataSets,ts,sigNames{sigId});
    end

    if isempty(fileName)
        runId=Simulink.sdi.createRun('RunName','vars',dataSets);
        Simulink.sdi.internal.moveRunToApp(runId,'stm');
    else

        save(fileName,'dataSets');
    end
