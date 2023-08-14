function hDoc=activateDocument(doc)




    hWord=rmiref.WordUtil.getApplication();
    hDocs=hWord.Documents;
    openCount=hDocs.count;
    found=0;
    for i=1:openCount;
        thisDoc=hDocs.Item(i);
        fullname=thisDoc.FullName;
        if rmiut.cmp_paths(doc,fullname)
            found=i;
            break
        end
    end
    if found>0
        hDoc=hWord.Documents.Item(found);
        hDoc.Activate;
    else


        if rmiut.isCompletePath(doc)
            fullPath=doc;
        else
            fullPath=rmiut.full_path(doc,pwd);
        end
        hDoc=hDocs.Open(fullPath,[],0);
    end
end
