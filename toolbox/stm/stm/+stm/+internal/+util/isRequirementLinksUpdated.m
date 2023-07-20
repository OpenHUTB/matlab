function hasChanges=isRequirementLinksUpdated(testFilePath)


    hasChanges=false;
    try
        hasChanges=rmitm.hasChanges(testFilePath);
    catch me
        warning(me.message);
    end
end