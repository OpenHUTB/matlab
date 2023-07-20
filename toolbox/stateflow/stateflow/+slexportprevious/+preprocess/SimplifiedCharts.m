function SimplifiedCharts(obj)




    if isR2014aOrEarlier(obj.ver)

        machine=getStateflowMachine(obj);
        if isempty(machine)
            return;
        end

        charts=sf('get',machine.Id,'.charts');
        for chart=charts
            if~isempty(sf('find',chart,'.stateMachineType','SIMPLIFIED_MACHINE'))

                if~sfprivate('is_reactive_testing_table_chart',chart)



                    obj.reportWarning('Stateflow:misc:SimplifiedSaveInPrevVersion',sf('get',chart,'.name'));
                end
            end
        end
        obj.appendRule('<chart<stateMachineType|SIMPLIFIED_MACHINE:repval MOORE_MACHINE>>');
    end

end


