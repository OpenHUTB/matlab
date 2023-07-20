function register_datatypes()






    if isempty(findtype('mech2.ErrorLevel'))
        schema.EnumType('mech2.ErrorLevel',{'none','warning','error'});
    end

    if isempty(findtype('mech2.RestrictedErrorLevel'))
        schema.EnumType('mech2.RestrictedErrorLevel',{'warning','error'});
    end

    if isempty(findtype('mech2.UnconfigurableError'))
        schema.EnumType('mech2.UnconfigurableError',{'error'});
    end

    if isempty(findtype('mech2.UnconfigurableWarning'))
        schema.EnumType('mech2.UnconfigurableWarning',{'warning'});
    end

end

