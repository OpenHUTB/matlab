function firepropertychanged(h)




    me=TflDesigner.getexplorer;
    root=me.getRoot;
    oldval=root.iseditorbusy;
    root.iseditorbusy=true;
    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyChangedEvent',h);

    root.iseditorbusy=oldval;