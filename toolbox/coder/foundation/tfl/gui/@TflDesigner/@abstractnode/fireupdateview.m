function fireupdateview(h)%#ok





    me=TflDesigner.getexplorer;
    root=me.getRoot;
    oldval=root.iseditorbusy;
    root.iseditorbusy=true;
    ed=DAStudio.EventDispatcher;

    ed.broadcastEvent('ListChangedEvent');
    root.iseditorbusy=oldval;