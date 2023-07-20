function loadSystem(modelFullPath,withCallbacks)





    [~,mdlName,ext]=fileparts(modelFullPath);
    if bdIsLoaded(mdlName)||strcmp(ext,'.slxp')
        return;
    end
    if withCallbacks
        load_system(modelFullPath);
        return;
    end







    Simulink.internal.newSystemFromFile(mdlName,modelFullPath,ExecuteCallbacks=false);




    slInternal('associate_with_file',mdlName,modelFullPath);

    if slfeature('VRedRearch')>0


        return;
    end



    mmgr=get_param(mdlName,'MappingManager');
    mapping=mmgr.getActiveMappingFor('AutosarTarget');
    if~isa(mapping,'Simulink.AutosarTarget.ModelMapping')
        return;
    end
    mapping.unmap();
    mapping.AUTOSAR_ROOT=[];
    mmgr.deleteMapping(mapping);
end


