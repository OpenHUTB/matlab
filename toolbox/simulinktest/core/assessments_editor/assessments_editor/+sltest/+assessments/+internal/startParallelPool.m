function res=startParallelPool()
    poolobj=gcp('nocreate');
    res=false;
    if isempty(poolobj)
        parpool;
        res=true;
    end

end

