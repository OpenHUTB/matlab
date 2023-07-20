function exitJunctions(obj)




    if isR2021aOrEarlier(obj.ver)


        machineH=getStateflowMachine(obj);
        if isempty(machineH)
            return;
        end
        charts=machineH.find('-isa','Stateflow.Chart');
        for i=1:length(charts)
            ch=charts(i);
            exitJunctions=ch.find('-isa','Stateflow.Port');
            if~isempty(exitJunctions)
                obj.reportWarning('Stateflow:misc:ExitJunctionsInPrevVersion',ch.path);
            end

            for j=1:length(exitJunctions)
                delete(exitJunctions(j));
            end
        end
        obj.appendRule('<state<boundaryPorts:remove>>');
        obj.appendRule('<state<childPorts:remove>>');
        obj.appendRule('<chart<childPorts:remove>>');
    end
end
