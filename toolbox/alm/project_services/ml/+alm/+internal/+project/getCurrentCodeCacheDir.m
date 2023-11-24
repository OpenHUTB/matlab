function currentSimCache=getCurrentCodeCacheDir()

    cp=currentProject;
    if isprop(cp,'SimulinkCodeGenFolder')
        currentSimCache=char(cp.SimulinkCodeGenFolder);
    else
        currentSimCache='';
    end
end
