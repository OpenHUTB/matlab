function firelistchanged(h)




    me=TflDesigner.getexplorer;
    root=me.getRoot;
    editorbusyoldval=root.iseditorbusy;
    root.iseditorbusy=true;
    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('ListChangedEvent',h);
    root.iseditorbusy=editorbusyoldval;