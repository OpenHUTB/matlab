function hDoc=activateDocument(doc)




    hExcel=rmiref.ExcelUtil.getApplication();
    hDocs=hExcel.Workbooks;
    openCount=hDocs.count;
    found=0;
    for i=1:openCount
        thisDoc=hDocs.Item(i);
        fullname=thisDoc.FullName;
        if rmiut.cmp_paths(doc,fullname)
            found=i;
            break
        end
    end
    if found>0
        hDoc=hExcel.Workbooks.Item(found);
        hDoc.Activate;
    else
        hDoc=hDocs.Open(doc,[],0);
    end
end
