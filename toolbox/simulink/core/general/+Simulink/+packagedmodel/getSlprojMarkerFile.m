function result=getSlprojMarkerFile(model,purpose)



    cfg=Simulink.filegen.internal.FolderConfiguration.getCachedConfig(model);
    switch(purpose)
    case 'SIMULATION'
        cacheFolder=Simulink.fileGenControl('get','CacheFolder');
        result=fullfile(cacheFolder,cfg.Simulation.MarkerFile);
    case 'CODE_GENERATION'
        codeGenFolder=Simulink.fileGenControl('get','CodeGenFolder');
        result=fullfile(codeGenFolder,cfg.CodeGeneration.MarkerFile);
    otherwise
        DAStudio.error('Simulink:cache:unknownMode',purpose,mfilename);
    end
end