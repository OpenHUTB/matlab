function res=isSLRealTimeCompliant(model)





    cs=getActiveConfigSet(model);
    while isa(cs,'Simulink.ConfigSetRef')
        if~strcmpi(cs.SourceResolved,'on')
            res=false;
            return;
        end
        cs=cs.getRefConfigSet();
    end
    res=any(strcmp(get_param(cs,'SystemTargetFile'),{'slrealtime.tlc','slrt.tlc'}));
end
