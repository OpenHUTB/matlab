function concurrentAccess=isConcurrentAccess(hCSCDefn,hData)


    assert(isa(hData,'Simulink.Data'));
    if hCSCDefn.IsConcurrentAccessInstanceSpecific
        ca=hData.CoderInfo.CustomAttributes;
        concurrentAccess=ca.ConcurrentAccess;
    else
        concurrentAccess=hCSCDefn.ConcurrentAccess;
    end

