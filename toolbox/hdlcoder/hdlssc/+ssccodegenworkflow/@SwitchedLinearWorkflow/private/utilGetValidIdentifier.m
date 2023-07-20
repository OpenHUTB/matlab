function validIdentifier=utilGetValidIdentifier(identifier)






    maxlength=namelengthmax-20;
    if numel(identifier)>maxlength
        validIdentifier=identifier(1:maxlength);
    else
        validIdentifier=identifier;
    end
end