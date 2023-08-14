

function returnType=getReturnType(fcnPrototype)

    if isa(fcnPrototype.Return,'RTW.Argument')

        returnType=getTypeIdentifier(fcnPrototype.Return.Type);
    else
        returnType='void';
    end

end
