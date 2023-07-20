function yesno=isUpToDate(cacheFilePath,doc)


    if exist(cacheFilePath,'file')~=2
        yesno=false;
        return;
    end

    cacheInfo=dir(cacheFilePath);
    docInfo=dir(doc);
    if cacheInfo.datenum<docInfo.datenum
        yesno=false;
        return;
    end


    try
        myWord=actxGetRunningServer('word.application');
        yesno=~hasUnsavedChanges(myWord,doc);
    catch
        yesno=true;
    end
end

function result=hasUnsavedChanges(hWord,doc)
    hDocs=hWord.Documents;
    openCount=hDocs.count;
    result=false;
    for i=1:openCount;
        thisDoc=hDocs.Item(i);
        fullname=thisDoc.FullName;
        if rmiut.cmp_paths(doc,fullname)
            result=~thisDoc.Saved;
            break
        end
    end

end

