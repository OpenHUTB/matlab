function closePCTPool()


    pool=gcp('nocreate');
    if(~isempty(pool))
        delete(pool);
    end
end