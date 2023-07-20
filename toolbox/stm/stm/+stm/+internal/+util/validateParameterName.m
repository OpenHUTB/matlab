function validateParameterName(name)






    name=strtrim(name);
    mustBeNonzeroLengthText(name);
    validateattributes(name,["char","string"],{'scalartext','nonempty'});
    if~isempty(regexp(name,'[<>]','once'))
        MException(message('stm:Parameters:ValueCannotBeEmpty')).throw;
    end
end
