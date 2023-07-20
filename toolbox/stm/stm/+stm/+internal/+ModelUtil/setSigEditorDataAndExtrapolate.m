function activeScenario=setSigEditorDataAndExtrapolate(sigEditHdl,dataFile)







    InputScenario=load(dataFile);
    InputScenario=InputScenario.(char(fields(InputScenario)));

    ds=load(get_param(sigEditHdl,'Filename'));
    defaultScenario=ds.(get_param(sigEditHdl,'ActiveScenario'));


    emptySigNames=setdiff(defaultScenario.getElementNames,InputScenario.getElementNames);

    if~isempty(emptySigNames)
        for sig=emptySigNames









            sigToAdd=defaultScenario.getElement(char(sig));
            if~isa(sigToAdd,"Simulink.SimulationData.Signal")
                signal=Simulink.SimulationData.Signal;
                signal.Values=sigToAdd;
                signal.Name=char(sig);
                sigToAdd=signal;
            end
            InputScenario=InputScenario.addElement(sigToAdd);
        end
        save(dataFile,'InputScenario');
    end

    set_param(sigEditHdl,'Filename',dataFile);



    curr_active_scenario=get_param(sigEditHdl,'ActiveScenario');
    curr_active_signal=get_param(sigEditHdl,'ActiveSignal');
    num_of_scenarios=str2double(get_param(sigEditHdl,'NumberOfScenarios'));
    for sc=1:num_of_scenarios
        num_of_signals=str2double(get_param(sigEditHdl,'NumberOfSignals'));
        set_param(sigEditHdl,'ActiveScenario',sc);
        for sig=1:num_of_signals
            set_param(sigEditHdl,'ActiveSignal',sig);
            OutputAfterFinalValue=get_param(sigEditHdl,'OutputAfterFinalValue');
            if~strcmp(OutputAfterFinalValue,'Holding final value')
                set_param(sigEditHdl,'OutputAfterFinalValue',...
                'Holding final value');
            end
        end
    end
    set_param(sigEditHdl,'ActiveScenario',curr_active_scenario);
    set_param(sigEditHdl,'ActiveSignal',curr_active_signal);
    activeScenario=get_param(sigEditHdl,'ActiveScenario');
end
