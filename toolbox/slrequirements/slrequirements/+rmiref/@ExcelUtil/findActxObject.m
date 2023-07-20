function[docitem,button,idx]=findActxObject(doc,item)




    docobj=rmiref.DocCheckExcel.activateDocument(doc);
    oleObjects=docobj.ActiveSheet.OLEObjects;
    docitem=[];
    button=[];
    idx=0;
    for i=1:oleObjects.Count
        oleObject=oleObjects.Item(i);
        try
            btnObj=oleObject.Object;
            if strcmp(btnObj.Name,item)
                docitem=oleObject;
                button=btnObj;
                idx=i;
                break;
            end
        catch Mex %#ok<NASGU>


            continue;
        end
    end
end
