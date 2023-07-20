function generatedName=generateName(requestedName,allNames)






    if isempty(allNames)
        generatedName=requestedName;
        return;
    end



    startOfNumSuffix=regexp(requestedName,'(\d)+$');
    if~isempty(startOfNumSuffix)
        rootName=requestedName(1:startOfNumSuffix-1);
    else
        rootName=requestedName;
    end





    generatedName=genvarname(rootName,allNames);
end