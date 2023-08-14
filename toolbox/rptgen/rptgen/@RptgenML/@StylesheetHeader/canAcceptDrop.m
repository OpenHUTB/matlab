function tf=canAcceptDrop(this,dropObjects)






    tf=true;
    for i=1:length(dropObjects)
        if isa(dropObjects(i),'RptgenML.StylesheetHeaderCell')
            tf=true;
        else
            tf=canAcceptDrop(this.up,dropObjects(i));
        end
        if~tf
            return;
        end
    end
