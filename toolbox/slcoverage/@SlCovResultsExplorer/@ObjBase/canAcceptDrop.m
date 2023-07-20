function tf=canAcceptDrop(obj,dropObjects)




    tf=false;
    for i=1:numel(dropObjects)
        co=dropObjects(i);
        if~obj.m_main.canAcceptDrop(obj.m_impl,co.m_impl)
            return;
        end
    end
    tf=true;