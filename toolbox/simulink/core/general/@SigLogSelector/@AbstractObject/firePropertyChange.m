function firePropertyChange(h)






    if isa(h,'SigLogSelector.AbstractNode')
        if~strcmp(h.Name,h.daobject.Name)
            h.Name=h.daobject.Name;
            h.CachedFullName=...
            Simulink.SimulationData.BlockPath.manglePath(h.daobject.getFullName);
        end
    end
    daevents.broadcastEvent('PropertyChangedEvent',h);

end
