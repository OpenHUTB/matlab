function initializeFastRestart(this,simWatcher,simInputs)





    prop='InitializeInteractiveRuns';
    if simWatcher.fastRestart&&~isfield(simWatcher.cleanupTestCase,prop)
        simWatcher.cleanupTestCase.(prop)=get_param(this.modelToRun,prop);
        set_param(this.modelToRun,prop,'on');

        if~isempty(simInputs.IterationId)&&this.runUsingSimIn
            signals=markLoggedFromAllSignalSets(simInputs,simWatcher);
            if~isempty(signals)
                simWatcher.cleanupTestCase.FastRestartLoggedSignals=signals;
            end
        end
    end
end

function signals=markLoggedFromAllSignalSets(simInputs,simWatcher)

    sets=stm.internal.getLoggedSignalSets(simInputs.PermutationId,true);
    if isempty(sets)
        signals=[];
        return;
    end




    find_mdlrefs(simWatcher.modelToRun,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);

    signals=arrayfun(@(id)stm.internal.getLoggedSignals(id,true,true),...
    [sets.id],'Uniform',false);
    signals=arrayfun(@(signal)Simulink.SimulationData.SignalLoggingInfo(...
    signal.BlockPath,signal.PortIndex),[signals{:}]);
    signals=markSignalsToLog(signals);
end

function signalsToLog=markSignalsToLog(sigs)
    signalsToLog=[];
    for idx=1:numel(sigs)
        bPath=sigs(idx).BlockPath.convertToCell;
        ph=get_param(bPath{end},'PortHandles');
        ph=ph.Outport(sigs(idx).OutputPortIndex);
        if strcmp(get_param(ph,'DataLogging'),'off')

            set_param(ph,'DataLogging','on');
            signalsToLog=[signalsToLog,sigs(idx)];%#ok<AGROW>
        end
    end
end
