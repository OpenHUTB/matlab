function err=checkValidControlVarValue(v)




    err=[];
    ok=slvariants.internal.config.utils.isValidControlVarValue(v);
    if~ok
        err=MException(message('Simulink:Variants:InvalidControlVarValue'));
    end
end
