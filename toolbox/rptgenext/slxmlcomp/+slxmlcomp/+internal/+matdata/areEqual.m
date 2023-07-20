function same=areEqual(leftFilePath,leftVariablePath,rightFilePath,rightVariablePath)



    import slxmlcomp.internal.matdata.MatDataCache;

    leftVariable=MatDataCache.get(leftFilePath,leftVariablePath);
    rightVariable=MatDataCache.get(rightFilePath,rightVariablePath);

    match=comparisons.internal.variablesEqual(leftVariable,rightVariable);
    same=strcmp(match,'yes');

end
