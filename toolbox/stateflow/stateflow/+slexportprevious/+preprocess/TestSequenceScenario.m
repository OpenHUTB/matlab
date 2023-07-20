function TestSequenceScenario(obj)





    if isR2020aOrEarlier(obj.ver)


        machineH=getStateflowMachine(obj);
        if isempty(machineH)
            return;
        end
        charts=machineH.find('-isa','Stateflow.ReactiveTestingTableChart');
        for i=1:length(charts)
            ch=charts(i);
            dataArray=ch.find('-isa','Stateflow.Data','Scope','Parameter');
            dataIdArray=arrayfun(@(dataH)dataH.Id,dataArray);
            scenarioParameterId=sf('find',dataIdArray,'.props.isScenario',1);

            if~isempty(scenarioParameterId)
                sttman=Stateflow.STT.StateEventTableMan(ch.Id);
                sttman.deleteDefaultTransitionPathRow(2);
                obj.reportWarning('Stateflow:reactive:TestSequenceScenarioInPrevVersion',ch.path);
            end
        end
    end
end
