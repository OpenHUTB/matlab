function[docitem,button,idx]=findActxObject(doc,item)




    docobj=rmiref.WordUtil.activateDocument(doc);
    allShapes=docobj.InlineShapes;
    docitem=[];
    button=[];
    idx=0;
    for i=1:allShapes.Count
        shapeObj=allShapes.Item(i);
        oleFormat=shapeObj.OLEFormat;
        try
            btnObj=oleFormat.Object;
            if strcmp(btnObj.Name,item)
                docitem=shapeObj;
                button=btnObj;
                idx=i;
                break;
            end
        catch Mex %#ok<NASGU>


            continue;
        end
    end
end
