function tf=canAcceptDrop(this,dropObjects)







    tf=true;
    for i=1:length(dropObjects)
        tf=isa(dropObjects(i),'RptgenML.ComponentMakerData');
        if~tf
            return;
        end
    end
