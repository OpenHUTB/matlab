function SimulinkBasedStates(obj)





    machineH=getStateflowMachine(obj);
    if isempty(machineH)
        return;
    end

    if isR2017aOrEarlier(obj.ver)
        charts=machineH.find('-isa','Stateflow.Chart');
        for i=1:length(charts)
            ch=charts(i);
            if~ishandle(ch)

                continue
            end
            simulinkStates=ch.find('-isa','Stateflow.SimulinkBasedState');
            if~isempty(simulinkStates)
                obj.reportWarning('Stateflow:misc:SimulinkStatesInPrevVersion',ch.path);
            end
        end
    end

end
