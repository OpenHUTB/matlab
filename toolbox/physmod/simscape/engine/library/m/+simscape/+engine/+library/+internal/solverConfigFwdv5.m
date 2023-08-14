function out=solverConfigFwdv5(in)
    map={
    {
    {'PartitionMethod',{'FAST','ROBUST'}}
    {'PartitionMethod',{'FAST','ROBUST'}}
    }
    };
    out=simscape.engine.library.internal.mapParameters(in,map);
end
