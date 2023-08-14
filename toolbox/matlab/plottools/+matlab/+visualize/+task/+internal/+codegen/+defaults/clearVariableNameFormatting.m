function varName=clearVariableNameFormatting(varName)













    if contains(varName,'.')
        varName=extractAfter(varName,'.');
        varName=replace(varName,["(",")","'"],'');
    end
end