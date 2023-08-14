function[contains,entries]=containsEntry(hObj,entryName)






    if~iscell(entryName)
        entryName={entryName};
    end
    nNames=numel(entryName);
    entries=cell(1,nNames);
    contains=false(1,nNames);
    isLibraryInDatabase=isfield(hObj.Entries,entryName);
    entriesInDatabase=entryName(isLibraryInDatabase);
    nInDatabase=numel(entriesInDatabase);
    containsEntry=false(1,nInDatabase);
    dbEntries=cell(1,nInDatabase);
    for idx=1:nInDatabase
        entry=hObj.Entries.(entriesInDatabase{idx});
        containsEntry(idx)=entry.validate();
        if nargout==2
            dbEntries{idx}=entry;
        end
    end

    contains(isLibraryInDatabase)=containsEntry;
    if nargout==2
        entries=cell(1,nNames);
        entries(isLibraryInDatabase)=dbEntries;
    end
end
