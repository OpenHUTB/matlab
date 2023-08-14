function changePlatform(platformId,cbinfo)




    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;

    pb=Simulink.internal.ScopedProgressBar(...
    DAStudio.message('autosarstandard:editor:ConfigInterfaceDictProgressUI'));
    c=onCleanup(@()delete(pb));





    builtInPlatformIds=guiObj.getBuiltInPlatformIds();
    if any(contains(builtInPlatformIds,platformId))
        platformsIdsMappedToDict=guiObj.getMappedPlatformIds();
        if~any(contains(platformsIdsMappedToDict,platformId))
            guiObj.addPlatformMapping(platformId);
        end
    end

    guiObj.changePlatform(platformId);
end


