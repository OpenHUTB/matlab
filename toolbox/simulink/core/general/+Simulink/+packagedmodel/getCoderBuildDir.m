function result=getCoderBuildDir(model,aToken)



    cfg=Simulink.filegen.internal.FolderConfiguration.getCachedConfig(model);
    aSet=cfg.getFolderSetFor('RTW');
    result=aSet.(aToken);
end