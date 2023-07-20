function updateEngineDirtyFlag(this,appName,filename,dirtyBit)

    [pathname,shortFilename,extension]=fileparts(filename);
    ctrl=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    ctrl.cacheSessionInfo(...
    [shortFilename,extension],...
    pathname);
end
