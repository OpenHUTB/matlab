function out=solverConfigFwdv4(in)
    map={
    {
    {'PartitioningCachingChoice',{'ONLINE','OFFLINE'}}
    {'PartitionStorageMethod',{'AS_NEEDED','EXHAUSTIVE'}}
    }
    {
    {'PartitioningCachingBudget','1024'}
    {'PartitionMemoryBudget','1024'}
    }
    };
    out=simscape.engine.library.internal.mapParameters(in,map);
end
