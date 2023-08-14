function tf=acceptDrop(this,dropObjects)




    tf=false;

    if isempty(dropObjects)
        return;
    end

    for i=length(dropObjects):-1:1
        if isa(dropObjects(i),'RptgenML.ComponentMakerData')
            tf=true;
            droppedObject=dropObjects(i);
            droppedObject=this.addProperty(droppedObject);
            droppedObject.updateErrorState;
        elseif isa(dropObjects(i),'rptgen.rptcomponent')
            tf=true;
            droppedObject=this;
            this.loadComponent(dropObjects(i));
        elseif isa(dropObjects(i),'RptgenML.LibraryComponent')
            tf=true;
            droppedObject=this;
            this.loadComponent(dropObjects(i).makeComponent);
        end
    end

    r=RptgenML.Root;
    if~isempty(r.Editor)&&tf
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',r);

        r.Editor.view(droppedObject);
    end


