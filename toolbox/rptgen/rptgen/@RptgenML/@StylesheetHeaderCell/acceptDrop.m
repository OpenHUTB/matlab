function tf=acceptDrop(this,dropObjects)




    tf=false;

    if isLibrary(this)||isempty(dropObjects)
        return;
    end

    droppedObject=[];
    thisParentNode=this.JavaHandle.getParentNode;
    for i=length(dropObjects):-1:1
        if dropObjects(i)==this

        elseif isa(dropObjects(i),'RptgenML.StylesheetHeaderCell')
            try
                droppedObject=RptgenML.createStylesheetElement(this.up,...
                dropObjects(i),...
                this);
            catch
                droppedObject=[];
            end

            if~isempty(droppedObject)
                tf=true;



                this.setDirty(true);
            end
        elseif isa(dropObjects(i),'RptgenML.StylesheetElement')&&~isempty(this.up)
            tf=max(tf,acceptDrop(this.up,dropObjects(i)));
        else

        end
    end

    r=RptgenML.Root;
    if~isempty(r.Editor)&&~isempty(droppedObject)
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',r);

        r.Editor.view(droppedObject);
    end
