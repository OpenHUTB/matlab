function tf=acceptDrop(this,dropObjects)




    tf=false;

    if isempty(dropObjects)
        return;
    end

    for i=length(dropObjects):-1:1
        if isa(dropObjects(i),'RptgenML.ComponentMakerData')



            if dropObjects(i)~=this
                tf=true;
                if isLibrary(dropObjects(i))
                    droppedObject=copy(dropObjects(i));
                else
                    droppedObject=dropObjects(i);
                end
                connect(droppedObject,this,'left');
                droppedObject.updateErrorState;
            end
        end
    end

    r=RptgenML.Root;
    if~isempty(r.Editor)&&tf
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',r);

        r.Editor.view(droppedObject);
    end

