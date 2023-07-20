function result=cacheDiscreteEventSignalPorts()

    result=[];


    runIDs=Simulink.sdi.getAllRunIDs;
    runID=runIDs(end);
    run=Simulink.sdi.getRun(runID);
    numSignals=run.SignalCount;
    engine=Simulink.sdi.Instance.engine;

    for i=1:numSignals

        sigID=run.getSignalIDByIndex(i);

        if engine.sigRepository.getSignalIsEventBased(sigID)

            signal=run.getSignalByIndex(i);
            result=[result,struct('BlockPath',signal.FullBlockPath,...
            'PortIndex',signal.PortIndex)];%#ok<AGROW> 
        end

    end
end

