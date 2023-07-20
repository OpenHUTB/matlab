function bool=highlight(obj,objectId,posStart,posEnd)




    ed=obj.open(objectId);
    if isempty(ed)
        bool=false;
    else
        ed.highlight(posStart,posEnd);
        bool=true;
    end


