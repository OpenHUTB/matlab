function pAll=getAndCleanupUiscopesManagerInstances


    pAll=internal.manager('polariInstance','get');
    for i=1:numel(pAll)
        if~isvalid(pAll(i))
            internal.manager('polariInstance','remove',pAll(i));
        end
    end
    pAll=internal.manager('polariInstance','get');

end
