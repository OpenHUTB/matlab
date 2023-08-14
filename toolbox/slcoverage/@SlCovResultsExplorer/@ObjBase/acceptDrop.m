function tf=acceptDrop(obj,dropObjects)



    tf=true;

    for i=1:numel(dropObjects)
        co=dropObjects(i);
        tf=obj.m_main.acceptDrop(obj.m_impl,co.m_impl);
    end

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('HierarchyChangedEvent',obj);
