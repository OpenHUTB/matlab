function nominalValues=getDefaultNominalValues





    try
        [value,unit]=simscape.compiler.mli.defaultNominalValues();

        nominalValues=simscape.nominal.internal.serializeSimscapeNominalValues(value,unit);
    catch ME
        ME.throwAsCaller();
    end

end
