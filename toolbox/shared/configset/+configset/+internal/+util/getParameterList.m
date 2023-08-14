function out=getParameterList(model)
















    cs=getActiveConfigSet(model);
    if isa(cs,'Simulink.ConfigSetRef')
        cs=cs.getRefConfigSet;
    end
    out=fieldnames(get_param(cs,'ObjectParameters'));
