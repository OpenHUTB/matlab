function names=getQualifiedParams(cs)




    cssd=configset.internal.getConfigSetStaticData;
    if isa(cs,'Simulink.ConfigSet')
        names1=cssd.getParamNames;
    else
        cmp=cs.Name;
        names1=cssd.getParamNames(cmp);
    end

    names2=setdiff(cs.getProp,names1);
    names=[names1;names2];
