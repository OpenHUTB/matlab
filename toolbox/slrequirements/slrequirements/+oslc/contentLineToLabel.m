function labelStr=contentLineToLabel(reqDoc,locStr,labelStr)







    projName=getFromParenth(reqDoc);
    itemId=getFromParenth(locStr);
    label=getFromParenth(labelStr);

    if isempty(projName)
        return;
    end

    if isempty(itemId)

        itemId=locStr;
    end

    if isempty(label)

        label=labelStr;
    end

    labelStr=oslc.makeLabel(itemId,label,projName);
end

function out=getFromParenth(in)

    op=find(in=='(');
    cp=find(in==')');
    if isempty(op)||isempty(cp)||cp(1)<op(1)
        out='';
    else
        out=in(op(1)+1:cp(end)-1);
    end
end

