function[sigs,plotIndices]=getCheckedSignals(runID)


    engine=Simulink.sdi.Instance.engine;
    sigs=engine.getAllSignalIDs(runID,'checked');
    plotIndices=cell(size(sigs));
    for x=1:length(sigs)
        plotLoc=engine.getSignalCheckedPlots(sigs(x));
        plotIndices{x}=plotLoc;
    end
end
