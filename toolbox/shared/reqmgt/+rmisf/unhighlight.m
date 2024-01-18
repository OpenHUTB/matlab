function unhighlight(modelName)
    machine=find(sfroot,'-isa','Stateflow.Machine','-and','Name',modelName);%#ok<GTARG>
    if~isempty(machine)
        machineID=machine.id;

        sf('ClearAltStyles',machineID);
        sf('Redraw',machineID);
    end
end