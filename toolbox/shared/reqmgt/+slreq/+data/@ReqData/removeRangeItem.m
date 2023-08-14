function success=removeRangeItem(~,textItemObj,id)







    if~isempty(textItemObj.id)
        id=slreq.utils.getLongIdFromShortId(textItemObj.id,id);
    end

    rangeObjs=textItemObj.textRanges;
    linkSetObj=textItemObj.artifact;
    for i=1:rangeObjs.Size
        rangeObj=rangeObjs.at(i);
        if strcmp(rangeObj.id,id)
            rangeObjs.removeAt(i);
            linkSetObj.items.remove(rangeObj);
            rangeObj.delete();
            success=true;
            return;
        end
    end
    success=false;
end
