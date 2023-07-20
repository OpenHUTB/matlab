function onProjectClosed(absoluteRootFolder)




    observer=alm.internal.GlobalProjectObserver.get();
    observer.emitProjectClosedEvent(absoluteRootFolder);
end
