function propValueChangeCallback(hObj,event)%#ok
    if(ismethod(hObj,'dirtyHostBD'))
        hObj.dirtyHostBD();
    end


