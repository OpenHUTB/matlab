function listenerCallback(changesReport)














    try
        observersDispatcher=autosar.mm.observer.ObserversDispatcher();
        observersDispatcher.broadcastChanges(changesReport);
    catch ME
        disp(ME.getReport());
        warning(ME.identifier,'%s',ME.message);
    end

end
