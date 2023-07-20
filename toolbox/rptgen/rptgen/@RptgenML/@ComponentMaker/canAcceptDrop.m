function tf=canAcceptDrop(this,dropObjects)







    tf=true;
    for i=1:length(dropObjects)
        tf=isa(dropObjects(i),'RptgenML.ComponentMakerData')||...
        isa(dropObjects(i),'RptgenML.LibraryComponent')||...
        isa(dropObjects(i),'rptgen.rptcomponent');
        if~tf
            return;
        end
    end


