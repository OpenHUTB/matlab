function currentSimCache=getCurrentSimulationCacheDir()

    cp=currentProject;
    if isprop(cp,'SimulinkCacheFolder')
        currentSimCache=char(cp.SimulinkCacheFolder);
    else
        currentSimCache='';
    end
end
