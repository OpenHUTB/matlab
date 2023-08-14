function StateTransitionTable(obj)


    machine=getStateflowMachine(obj);
    if isempty(machine)
        return;
    end

    NORMAL_CHART_TYPE=0;
    NULL=0;

    function scrubAutogen(uddH)

        sf('set',uddH.Id,'.autogen.isAutoCreated',NULL);
        sf('set',uddH.Id,'.autogen.source',NULL);
        sf('set',uddH.Id,'.autogen.mapping',NULL);
    end

    if isR2012aOrEarlier(obj.ver)
        sttCharts=machine.find('-isa','Stateflow.StateTransitionTableChart');
        for i=1:length(sttCharts)
            ch=sttCharts(i);
            chartName=ch.Name;
            sf('set',ch.Id,'.type',NORMAL_CHART_TYPE);
            tableId=sf('get',ch.Id,'.stateTable');
            sf('delete',tableId);
            sf('set',ch.Id,'.stateTable',NULL);

            states=ch.find('-isa','Stateflow.State');
            transitions=ch.find('-isa','Stateflow.Transition');
            junctions=ch.find('-isa','Stateflow.Junction');
            arrayfun(@scrubAutogen,states);
            arrayfun(@scrubAutogen,transitions);
            arrayfun(@scrubAutogen,junctions);

            obj.appendRule('<chart<stateTable:remove>>');
            obj.reportWarning('Stateflow:misc:STTSaveInPrevVersion',chartName);
        end
    end
end