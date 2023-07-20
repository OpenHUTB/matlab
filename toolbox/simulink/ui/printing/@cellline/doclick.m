function A=doclick(A)





    figH=get(A,'Figure');
    figObjH=getobj(figH);
    selType=figObjH.SelectionType;

    switch selType
    case 'open'


    case 'normal'

        A.axischild=doclick(A.axischild);
    end
