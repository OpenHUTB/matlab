function msgList=configureSignalsForStreamingHelper(loggedSignals,bFromIteration,modelToRun,simWatcher)



    msgList={};
    if(simWatcher.modelLoggingInfoDone&&isa(simWatcher.modelLoggingInfo,'containers.Map'))


        models=simWatcher.cleanupTestCase.InstrumentedSignals.keys;
        for i=1:length(models)
            model=models{i};
            loggingIndex=0;
            existLoggings=simWatcher.cleanupTestCase.InstrumentedSignals(model);
            modelLoggingInfo=simWatcher.modelLoggingInfo(model);
            for k=1:length(existLoggings)
                so=Simulink.SimulationData.SignalLoggingInfo(existLoggings.get(k).BlockPath,existLoggings.get(k).OutputPortIndex);
                loggingIndex=loggingIndex+1;
                modelLoggingInfo.Signals(loggingIndex)=so;
            end
            simWatcher.modelLoggingInfo(model)=modelLoggingInfo;



            if strcmp(model,modelToRun)
                modelLoggingInfo=simWatcher.modelLoggingInfo(modelToRun);
                for k=1:length(loggedSignals)
                    so=Simulink.SimulationData.SignalLoggingInfo(loggedSignals(k).BlockPath,loggedSignals(k).PortIndex);
                    loggingIndex=loggingIndex+1;
                    modelLoggingInfo.Signals(loggingIndex)=so;
                end
                simWatcher.modelLoggingInfo(modelToRun)=modelLoggingInfo;
            end
        end

        for i=1:length(models)
            set_param(model,'DataLoggingOverride',simWatcher.modelLoggingInfo(model));
        end
    else
        if(~isempty(loggedSignals))
            [msgList,currInstrumentedSignals,dsmOverrides,modelToUse]=stm.internal.util.markOutputSignalsForStreaming(modelToRun,loggedSignals);
            if(bFromIteration)
                simWatcher.cleanupIteration.InstrumentedSignals=currInstrumentedSignals;
                simWatcher.cleanupIteration.DSMLoggingOverrides=dsmOverrides;
            else



                if(~isfield(simWatcher.cleanupTestCase,'InstrumentedSignals')||...
                    isempty(simWatcher.cleanupTestCase.InstrumentedSignals(modelToUse)))



                    simWatcher.cleanupTestCase.InstrumentedSignals=currInstrumentedSignals;
                end
                simWatcher.cleanupTestCase.DSMLoggingOverrides=dsmOverrides;
            end
        end
    end
end
