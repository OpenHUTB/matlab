function onProjectOpened(absoluteRootFolder)




    observer=alm.internal.GlobalProjectObserver.get();
    observer.emitProjectOpenedEvent(absoluteRootFolder);
end
