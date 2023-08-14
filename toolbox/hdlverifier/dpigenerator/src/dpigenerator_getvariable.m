


function value=dpigenerator_getvariable(prop)

    mgr=dpig.internal.VariableManager.getInstance;
    value=mgr.(prop);


    if ischar(value)
        value=slsvInternal('slsvEscapeServices','unescapeString',value);
    end

end