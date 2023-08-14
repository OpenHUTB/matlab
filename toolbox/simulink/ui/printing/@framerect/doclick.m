function A=doclick(A)





    figH=get(A,'Figure');
    figObjH=getobj(figH);
    selType=figObjH.SelectionType;

    selected=get(A,'IsSelected');

    switch selType
    case 'open'
    case 'normal'
        dragBinH=figObjH.DragObjects;
        for aObjH=dragBinH.Items;
            set(aObjH,'IsSelected',0);
        end
        A=set(A,'IsSelected',1);
    end
