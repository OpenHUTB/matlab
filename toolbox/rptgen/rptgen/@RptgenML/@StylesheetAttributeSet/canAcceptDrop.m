function tf=canAcceptDrop(this,dropObjects)






    tf=true;
    for i=1:length(dropObjects)
        if isa(dropObjects(i),'RptgenML.StylesheetAttribute')
            tf=true;
        elseif isa(dropObjects(i),'RptgenML.StylesheetHeaderCell')
            tf=false;
        else
            tf=canAcceptDrop(this.up,dropObjects(i));
        end
        if~tf
            return;
        end
    end
