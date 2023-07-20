function fireHierarchyChanged(h)




    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('HierarchyChangedEvent',h);

end
