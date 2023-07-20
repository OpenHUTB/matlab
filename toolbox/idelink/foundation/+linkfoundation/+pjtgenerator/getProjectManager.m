function[hPM,hTgt]=getProjectManager(modelName)




    cs=getActiveConfigSet(modelName);

    if isa(cs,'Simulink.ConfigSetRef')
        cs=cs.getRefConfigSet();
    end

    hTgt=linkfoundation.util.getTargetComponent(cs);

    try
        hPM=hTgt.ProjectMgr;
    catch e %#ok<NASGU>



        hPM=[];
    end
