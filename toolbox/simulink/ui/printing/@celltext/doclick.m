function A=doclick(A)






    figH=get(A,'Figure');
    figObjH=getobj(figH);
    selType=figObjH.SelectionType;

    selected=get(A,'IsSelected');

    switch selType
    case 'open'
        set(A,'Editing','on');
    case 'normal'

        myCell=get(A,'MyBin');
        doclick(myCell);
    case 'extend'

    end

