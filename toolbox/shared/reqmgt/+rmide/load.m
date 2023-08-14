function success=load(dictName,force)




    dictName=convertStringsToChars(dictName);

    if nargin==1
        force=false;
    end

    dictPath=rmide.getFilePath(dictName);

    if rmide.hasData(dictPath)
        if~force&&rmide.dictHasChanges(dictPath)
            reqFile=rmimap.StorageMapper.getInstance.getStorageFor(dictPath);
            error(message('Slvnv:rmide:HasUnsavedData',dictPath,reqFile));
        else
            rmide.discard(dictPath);
        end
    end
    success=slreq.utils.loadLinkSet(dictPath);
end

