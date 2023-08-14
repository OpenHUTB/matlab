function revertModelSettings(simWatcher)





    stm.internal.genericrealtime.FollowProgress.progress('begin: revertModelSettings()');
    endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: revertModelSettings()'));
    if(~isa(simWatcher.simModel,'stm.internal.util.SimulinkModel'))
        return;
    end
    revertAll=false;
    if(simWatcher.closeModel)
        revertAll=true;
    end

    if(simWatcher.modelSharingStatus>0)
        revertAll=true;
    end
    simWatcher.revertSettings(revertAll);

    closeHarness=false;
    if(simWatcher.modelSharingStatus>0)
        closeHarness=true;
    end
    if(simWatcher.closeModel)
        closeHarness=true;
    end
    if(closeHarness)
        simWatcher.restoreHarness();
    end

end
