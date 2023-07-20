function tf=canAcceptDrop(this,dropObjects)







    tf=true;
    for i=1:length(dropObjects)
        tf=isa(dropObjects(i),'RptgenML.LibraryRpt')||...
        isa(dropObjects(i),'RptgenML.FileConverter')||...
        isa(dropObjects(i),'rptgen.coutline')||...
        isa(dropObjects(i),'RptgenML.ComponentMaker');
        if~tf
            return;
        end
    end
