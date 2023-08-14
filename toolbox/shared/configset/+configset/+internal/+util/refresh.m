function refresh(hSrc)



    if~isa(hSrc,'Simulink.ConfigSet')
        return;
    end

    csc=hSrc.getConfigSetCache;
    if isempty(csc)
        return;
    end

    if length(csc.Components)<8||length(csc.Components(8).Components)<2
        return;
    end

    adps=configset.internal.util.getAllAdapters(csc.down);
    for i=1:length(adps)
        adp=adps{i};
        adp.resetAdapter();
    end

