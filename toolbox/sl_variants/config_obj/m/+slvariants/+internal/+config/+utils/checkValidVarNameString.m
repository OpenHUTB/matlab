function err=checkValidVarNameString(s)




    err=[];
    if Simulink.variant.utils.isCharOrString(s)
        s=strtrim(s);
    end
    ok=isvarname(s);
    if~ok
        err=MException(message('Simulink:Variants:InvalidVariableName'));
    end
end
