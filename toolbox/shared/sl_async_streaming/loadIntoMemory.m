function ds=loadIntoMemory(ds)










    if isa(ds,'Simulink.SimulationOutput')
        Simulink.sdi.internal.safeTransaction(@locLoadSimulationOutput,ds);
    elseif isa(ds,'Simulink.SimulationData.Dataset')
        Simulink.sdi.internal.safeTransaction(@locLoadDataset,ds);
    end
end


function locLoadSimulationOutput(ds)
    len=numel(ds);
    for idx=1:len
        vars=who(ds(idx));
        for idx2=1:length(vars)
            var=get(ds(idx),vars{idx2});
            if isa(var,'Simulink.SimulationData.Dataset')
                locLoadDataset(var)
            end
        end
    end
end


function locLoadDataset(ds)
    len=numel(ds);
    for idx=1:len
        storage=getStorage(ds(idx),false);
        if isa(storage,'Simulink.sdi.internal.DatasetStorage')
            fullyLoadCache(storage);
        end
    end
end