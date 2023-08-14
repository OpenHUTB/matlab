function revertModelSettings(simWatcher)





    stm.internal.slrealtime.FollowProgress.progress('-- Start: Revert model settings --');
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
    stm.internal.slrealtime.FollowProgress.progress('-- End: Revert model settings --');

end

