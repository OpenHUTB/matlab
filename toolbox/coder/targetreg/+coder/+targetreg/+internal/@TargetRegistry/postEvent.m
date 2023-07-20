function postEvent(hThis,anEvent)


    if~isempty(hThis.Listeners)
        registeredListeners=hThis.Listeners;
        for idx=1:length(registeredListeners)
            registeredListeners{idx}.event(anEvent);
        end
    end
