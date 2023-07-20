function addListeners(h)





    h.listeners=...
    Simulink.listener(h.daobject,'NameChangeEvent',...
    @(s,e)locFirePropertyChange(h,e));

end


function locFirePropertyChange(h,e)


    h.CachedFullName=...
    Simulink.SimulationData.BlockPath.manglePath(e.Source.getFullName);
    h.firePropertyChange;

end


