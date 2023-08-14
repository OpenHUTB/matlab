function saveRequirementLinks(testFile)


    if rmitm.hasChanges(testFile)
        rmitm.save(testFile);
    end
end
