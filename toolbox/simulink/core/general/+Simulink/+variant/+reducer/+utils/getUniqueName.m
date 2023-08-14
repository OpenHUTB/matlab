function generatedName=getUniqueName(requestedName,allNames)





    if isempty(allNames)
        generatedName=requestedName;
        return;
    end

    generatedName=matlab.lang.makeValidName(...
    matlab.lang.makeUniqueStrings(requestedName,allNames));
end
