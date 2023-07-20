function params=parameters(componentName)






    fullPath=simscape.smt.internal.get_full_path(componentName);


    params=simscape.smt.internal.get_info(fullPath,@lextractor,@simscape.smt.ParamInfo.empty);
end



function info=lextractor(name,field)
    info=simscape.smt.ParamInfo.empty;
    if strcmp(field.Class,'parameter')==1
        fv=field.Value;
        info=simscape.smt.ParamInfo(name,fv.value(fv.unit),fv.unit);
    end
end
