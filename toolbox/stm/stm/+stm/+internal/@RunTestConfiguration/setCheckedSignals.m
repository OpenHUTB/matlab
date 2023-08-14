function setCheckedSignals(sigs,plotIndices)


    engine=Simulink.sdi.Instance.engine;
    for x=1:length(sigs)
        engine.setSignalCheckedPlots(sigs(x),plotIndices{x});
    end
end
