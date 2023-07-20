function numberOfWorkers=getNumberOfParallelWorkers()







    p=gcp('nocreate');
    if isempty(p)
        numberOfWorkers=0;
    else
        numberOfWorkers=p.NumWorkers;
    end
end

