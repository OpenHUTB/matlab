function[res,isCpp]=isGrtCompliant(model)





    cs=getActiveConfigSet(model);
    while isa(cs,'Simulink.ConfigSetRef')
        if~strcmpi(cs.SourceResolved,'on')
            res=false;
            isCpp=[];
            return;
        end
        cs=cs.getRefConfigSet();
    end
    res=cs.getComponent('Code Generation').getComponent('Target').isGRTTarget;
    isCpp=strcmp(get_param(cs,'TargetLang'),'C++')&&...
    strcmp(get_param(cs,'CodeInterfacePackaging'),'C++ class');
end
