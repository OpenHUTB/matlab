function revertModelSettingsAfterSimulation(simWatcher)





    revertAll=false;
    closeHarness=false;
    if simWatcher.closeModel||simWatcher.modelSharingStatus>0
        revertAll=true;
        closeHarness=true;
    end
    simWatcher.revertSettings(revertAll);
    if closeHarness
        simWatcher.restoreHarness();
        simWatcher.restoreReferencedModels();
    end

end
