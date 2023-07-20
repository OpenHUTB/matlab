function inMemoryHarnessName=getHarnessMemName(modelPath,harnessName,rename)





    persistent nameVersion;

    import slxmlcomp.internal.testharness.MemoryNames;
    if rename
        existing=MemoryNames.get(modelPath,harnessName);
        if~isempty(existing)
            inMemoryHarnessName=existing;
            return
        end

        if(isempty(nameVersion))
            nameVersion=0;
        end
        nameVersion=nameVersion+1;

        inMemoryHarnessName=slxmlcomp.internal.testharness.getTempName(harnessName,nameVersion);
        while bdIsLoaded(inMemoryHarnessName)
            inMemoryHarnessName=slxmlcomp.internal.testharness.getTempName(harnessName,nameVersion);
            nameVersion=nameVersion+1;
        end
    else
        inMemoryHarnessName=harnessName;
    end

    MemoryNames.put(modelPath,harnessName,inMemoryHarnessName);
end
