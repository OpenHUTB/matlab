function fireHierarchyChange(h)





    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('HierarchyChangedEvent',h)


