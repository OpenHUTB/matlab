function pAll=getAndCleanupUiscopesManagerInstances


    pAll=internal.manager('smithplotInstance','get');
    for i=1:numel(pAll)
        if~isvalid(pAll(i))
            internal.manager('smithplotInstance','remove',pAll(i));
        end
    end
    pAll=internal.manager('smithplotInstance','get');

end
