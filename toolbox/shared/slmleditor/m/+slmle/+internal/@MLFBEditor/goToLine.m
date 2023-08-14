function bool=goToLine(obj,lineNum)

    if~isempty(lineNum)&&lineNum>=0
        data.lineNum=lineNum;
        obj.publish('highlightLine',data);
        bool=true;
    else
        bool=false;
    end

