function[res,isCpp]=isErtCompliant(model)





    cs=getActiveConfigSet(model);
    while isa(cs,'Simulink.ConfigSetRef')
        if~strcmpi(cs.SourceResolved,'on')
            res=false;
            isCpp=[];
            return;
        end
        cs=cs.getRefConfigSet();
    end
    res=strcmp(get_param(cs,'IsERTTarget'),'on');
    isCpp=strcmp(get_param(cs,'TargetLang'),'C++')&&...
    strcmp(get_param(cs,'CodeInterfacePackaging'),'C++ class');
end
