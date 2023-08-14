function BusObjects=getSimulinkBusObjects(system)




    BusObjects=[];

    sysRoot=bdroot(system);
    vars=Simulink.findVars(system,'SearchMethod','cached');

    for i=1:length(vars)
        if existsInGlobalScope(sysRoot,vars(i).Name)
            Obj=evalinGlobalScope(sysRoot,vars(i).Name);
            if isa(Obj,'Simulink.Bus')
                bObj.Name=vars(i).Name;
                bObj.Object=Obj;
                bObj.Users=vars(i).Users;
                BusObjects=[BusObjects;bObj];%#ok<*AGROW>
            end
        end
    end
end

