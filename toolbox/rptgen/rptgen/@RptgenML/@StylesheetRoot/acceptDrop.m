function tf=acceptDrop(this,dropObjects)




    tf=false;

    if isempty(dropObjects)
        return;
    end

    for i=1:length(dropObjects)
        if isa(dropObjects(i),'RptgenML.StylesheetEditor')
            tf=true;
            droppedObject=this.addStylesheetEditor(dropObjects(i));
        elseif isa(dropObjects(i),'rptgen.coutline')||...
            isa(dropObjects(i),'rpt_xml.db_output')
            tf=true;
            droppedObject=RptgenML.StylesheetEditor(dropObjects(i));
            connect(droppedObject,this,'up');
        else

        end
    end

    r=RptgenML.Root;
    if~isempty(r.Editor)&&tf
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',r);

        r.Editor.view(droppedObject);


    end


