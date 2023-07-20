function modelH=updateModelHandleIfObsMdl(modelH)






    obsPorts=Simulink.observer.internal.getObserverPortsInsideObserverModel(modelH);
    if~isempty(obsPorts)
        obsRefBlkCtx=Simulink.observer.internal.getObsRefBlkCtx(modelH);

        if obsRefBlkCtx~=-1
            modelH=bdroot(obsRefBlkCtx);
        end
    end
end
