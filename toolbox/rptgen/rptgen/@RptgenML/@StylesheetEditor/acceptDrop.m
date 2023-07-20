function tf=acceptDrop(this,dropObjects)




    tf=false;

    if isempty(dropObjects)
        return;
    end

    for i=length(dropObjects):-1:1
        if isa(dropObjects(i),'RptgenML.StylesheetAttribute')||isa(dropObjects(i),'RptgenML.StylesheetHeaderCell')

        elseif isa(dropObjects(i),'RptgenML.StylesheetElement')
            tf=true;
            droppedObject=dropObjects(i);
            droppedObject=this.addData(droppedObject,'-first');
            this.setDirty(true);







        else

        end
    end

    r=RptgenML.Root;
    if~isempty(r.Editor)&&tf
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',r);

        r.Editor.view(droppedObject);


    end


