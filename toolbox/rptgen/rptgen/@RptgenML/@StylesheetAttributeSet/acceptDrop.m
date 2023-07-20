function tf=acceptDrop(this,dropObjects)





    tf=false;
    if isLibrary(this)||isempty(dropObjects)
        return;
    end

    droppedObject=[];
    thisParentNode=this.JavaHandle.getParentNode;
    for i=1:length(dropObjects)
        if isa(dropObjects(i),'RptgenML.StylesheetAttribute')
            droppedObject=RptgenML.StylesheetAttribute(this,dropObjects(i),'-first');
            tf=true;
        elseif dropObjects(i)==this

        elseif isa(dropObjects(i),'RptgenML.StylesheetHeaderCell')

        elseif isa(dropObjects(i),'RptgenML.StylesheetElement')

            try
                droppedObject=RptgenML.createStylesheetElement(this.up,dropObjects(i),...
                this);
            catch
                droppedObject=[];
            end

            if~isempty(droppedObject)
                tf=true;



                this.setDirty(true);
            end
        else

        end
    end

    r=RptgenML.Root;
    if~isempty(r.Editor)&&~isempty(droppedObject)
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',r);

        r.Editor.view(droppedObject);
    end

