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
        myExcel=actxGetRunningServer('excel.application');
        yesno=~hasUnsavedChanges(myExcel,doc);
    catch
        yesno=true;
    end
end

function result=hasUnsavedChanges(hExcel,doc)
    hDocs=hExcel.Workbooks;
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

