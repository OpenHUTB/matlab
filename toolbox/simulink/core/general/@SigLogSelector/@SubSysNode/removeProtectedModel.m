function removeProtectedModel(h,hMdlNode)







    blk=h.childNodes.getDataByKey(hMdlNode.daobject.Name);
    h.childNodes.deleteDataByKey(hMdlNode.daobject.Name);
    blk.unpopulate;
    blk.signalsPopulated=true;


    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('ChildRemovedEvent',h,blk);



    me=SigLogSelector.getExplorer;
    me.getRoot.modelBlockAddedOrRemoved;

end
