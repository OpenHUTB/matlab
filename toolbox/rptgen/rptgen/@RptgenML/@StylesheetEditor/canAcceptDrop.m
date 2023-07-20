function tf=canAcceptDrop(this,dropObjects)







    tf=true;
    for i=1:length(dropObjects)
        if isa(dropObjects(i),'RptgenML.StylesheetAttribute')||isa(dropObjects(i),'RptgenML.StylesheetHeaderCell')
            tf=false;
            return;
        elseif isa(dropObjects(i),'RptgenML.StylesheetElement')






        else
            tf=false;
            return;
        end
    end


