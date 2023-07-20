function pool=getCurrentParallelPool







    try
        pool=gcp('nocreate');
    catch me %#ok<NASGU>

        pool=[];
    end
end