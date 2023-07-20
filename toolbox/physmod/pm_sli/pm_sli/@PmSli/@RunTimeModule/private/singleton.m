function singletonObj=singleton










    persistent pSingletonObj;

    if doDebug
munlock
    else
mlock
    end

    if isempty(pSingletonObj)
        pSingletonObj=PmSli.RunTimeModule;
        pSingletonObj.objectDate=datestr(now);
    end

    singletonObj=pSingletonObj;
end
