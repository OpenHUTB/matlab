


function applyLoggingSettings(this)
    import stm.internal.SimulationInput;
    import stm.internal.SignalLoggingTypes;

    loggedSignalSetId=this.SimIn.LoggedSignalSetId;
    if(~isempty(this.SimIn.testIteration.TestParameter.LoggedSignalSetId))
        loggedSignalSetId=this.SimIn.testIteration.TestParameter.LoggedSignalSetId;
    end
    if(~isempty(loggedSignalSetId)&&loggedSignalSetId>0)
        allLogged=stm.internal.getLoggedSignals(loggedSignalSetId,true,true);

        type=[allLogged.ElementType];
        loadModelsForLogging(allLogged(type==SignalLoggingTypes.DsmBlock|type==SignalLoggingTypes.SimulinkSignalObj));

        logged=allLogged(type==SignalLoggingTypes.LoggedSignal|...
        type==SignalLoggingTypes.BusLeafSignals|...
        type==SignalLoggingTypes.TopBusSignals);
        this.setLoggingSpecification(logged);

        dsmBlock=allLogged(type==SignalLoggingTypes.DsmBlock);
        this.setDsmBlock(dsmBlock);

        dsmSignal=allLogged(type==SignalLoggingTypes.SimulinkSignalObj);
        this.setDsmSimulinkSignal(dsmSignal);
    end

    appendAssessmentSignals(this);
end

function loadModelsForLogging(dsms)
    models=extractBefore({dsms.BlockPath},'/');
    load_system(models);
end

function appendAssessmentSignals(this)
    assessmentSignals=stm.internal.MRT.share.getAssessmentSignals(this.SimWatcher);
    if isempty(assessmentSignals)
        return;
    end

    loadModelsForLogging(assessmentSignals);
    this.setLoggingSpecification(assessmentSignals);
end
