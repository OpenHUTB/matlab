function vars=variables(componentName)






    fullPath=simscape.smt.internal.get_full_path(componentName);


    vars=simscape.smt.internal.get_info(fullPath,@lextractor,@simscape.smt.VariableInfo.empty);

end



function info=lextractor(name,field)
    info=simscape.smt.VariableInfo.empty;
    if strcmp(field.Class,'variable')==1
        fv=field.Value.value;
        info=simscape.smt.VariableInfo(name,fv.value(fv.unit),fv.unit);
    end
end
