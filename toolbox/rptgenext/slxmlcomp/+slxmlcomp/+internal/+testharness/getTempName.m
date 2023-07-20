function newName=getTempName(harnessName,counter)



    modifier=slxmlcomp.internal.testharness.MemoryNames.TempNameModifier;

    suffix=['_',modifier,'_',int2str(counter)];
    maxNameLength=namelengthmax-length(suffix);
    truncatedName=harnessName(1:min(length(harnessName),maxNameLength));
    newName=[truncatedName,suffix];
end
