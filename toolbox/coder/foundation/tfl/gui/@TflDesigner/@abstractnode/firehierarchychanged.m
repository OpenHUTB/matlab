function firehierarchychanged(h)




    me=TflDesigner.getexplorer;

    if~isempty(me)
        root=me.getRoot;
        editorbusyoldval=root.iseditorbusy;
        root.iseditorbusy=true;
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',h);
        root.iseditorbusy=editorbusyoldval;
    end