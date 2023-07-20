function res=isCppClassInterface(model)





    cs=getActiveConfigSet(model);
    while isa(cs,'Simulink.ConfigSetRef')
        if~strcmpi(cs.SourceResolved,'on')
            res=false;
            return;
        end
        cs=cs.getRefConfigSet();
    end
    res=strcmp(get_param(cs,'TargetLang'),'C++')&&...
    strcmp(get_param(cs,'CodeInterfacePackaging'),'C++ class');
end
