function docID=getUniqueDocID(storedValue,domain,refPath)












    docID=storedValue;
    linkDef=rmi.linktype_mgr('resolveByRegName',domain);
    if isempty(linkDef)

        return;
    elseif linkDef.isFile

        fullPathToDoc=slreq.uri.ResourcePathHandler.getFullPath(storedValue,refPath);
        if~isempty(fullPathToDoc)
            docID=fullPathToDoc;
        end
    elseif contains(storedValue,' (')


        docID=strtok(storedValue);
    end
end
