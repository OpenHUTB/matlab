function nWorkers=getPCTPool()


    pool=gcp('nocreate');
    nWorkers=0;
    if~isempty(pool)
        nWorkers=pool.NumWorkers;
    end
end
