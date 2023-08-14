function entries=getLibraryEntry(hObj,entryNames)












    narginchk(2,2);

    if iscell(entryNames)



        entries=[];
        for i=1:length(entryNames)
            entry=lGetEntry(hObj,entryNames{i});



            if isempty(entries)
                entries=entry;
            else
                entries(end+1)=entry;
            end
        end




        entries=reshape(entries,size(entryNames));

    else




        entries=lGetEntry(hObj,entryNames);

    end

end

function entry=lGetEntry(hObj,entryName)


    if~ischar(entryName)||~isfield(hObj.Entries,entryName)
        pm_error('physmod:pm_sli:PmSli:LibraryDatabase:InvalidEntryName',entryName);
    end

    entry=hObj.Entries.(entryName);




    if~strcmp(entry.Name,entryName)
        pm_error('physmod:pm_sli:PmSli:LibraryDatabase:LibraryDatabaseCorrupt',entryName);
    end

end

