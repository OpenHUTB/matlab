function generateHighlightObjDescription(hObj,hDlg)

    lhsDescription='';
    lhsObjPositionArray=sort(hDlg.getWidgetValue('tag_Available'));
    if~isempty(lhsObjPositionArray)
        lhsDescription=formatDescription(hObj.availableObjs,lhsObjPositionArray);
    end

    rhsDescription='';
    rhsObjPositionArray=sort(hDlg.getWidgetValue('tag_Selected'));
    if~isempty(rhsObjPositionArray)
        rhsDescription=formatDescription(hObj.selectedObjs,rhsObjPositionArray);
    end

    hObj.highlightObjDescription=[lhsDescription,rhsDescription];

end


function desc=formatDescription(objs,objPositionArray)
    sizes=size(objPositionArray);
    numHighlight=sizes(2);
    desc='';
    for i=1:numHighlight
        pos=objPositionArray(i)+1;
        desc=appendDescription(objs(pos).Name,objs(pos).Description,desc);
    end
end


function desc=appendDescription(objName,objDescription,oldDesc)
    if isempty(objDescription)
        objDescription='';
    end
    desc=sprintf([oldDesc,'<strong>',objName,':','</strong>','<br>',objDescription,'<br>','<br>']);
end
