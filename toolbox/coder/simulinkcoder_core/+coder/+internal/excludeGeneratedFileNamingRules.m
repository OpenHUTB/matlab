function optsArray=excludeGeneratedFileNamingRules(optsArray)







    optsNames={optsArray.name};
    excludeInices=...
    strcmp('ERTHeaderFileRootName',optsNames)|...
    strcmp('ERTSourceFileRootName',optsNames)|...
    strcmp('ERTDataFileRootName',optsNames);
    optsArray=optsArray(~excludeInices);
end


