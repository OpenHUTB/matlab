function update(hSrc,paramName)



    if isa(hSrc,'Simulink.BaseConfig')
        cs=hSrc.getConfigSet;
        if isempty(cs)
            adps=configset.internal.util.getAllAdapters(hSrc.down);
        else
            adps=configset.internal.util.getAllAdapters(cs.down);
        end
        for i=1:length(adps)
            adp=adps{i};
            adp.update(hSrc,paramName);
        end
    end

