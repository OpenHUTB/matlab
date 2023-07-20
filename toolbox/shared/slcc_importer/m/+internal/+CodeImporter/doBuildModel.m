function doBuildModel(obj)


    [hMdl,tmpMdlPath]=internal.CodeImporter.createTempModel(obj);
    outputFolder=obj.qualifiedSettings.OutputFolder;
    projRootDir=cgxeprivate('get_cgxe_proj_root');
    cachePath=fullfile(projRootDir,'slprj');
    keepCache=isfolder(cachePath);



    function rmTmpLib(mdl,mdlPath,keepCache,cachePath,outputFolder)
        close_system(mdl,0);
        delete(mdlPath);
        if startsWith(cachePath,outputFolder,'IgnoreCase',ispc)&&isfolder(cachePath)&&~keepCache
            slcc('unloadCustomCodeDLLs');
            rmdir(cachePath,'s');
        end
    end
    modelCleaner=onCleanup(@()rmTmpLib(hMdl,tmpMdlPath,keepCache,cachePath,outputFolder));

    try
        if obj.Options.BuildForIPProtection
            SLCC.OOP.PrebuiltCC.build(hMdl);
        else
            slcc('parseCustomCode',hMdl,true);
            slcc('buildCustomCodeForModel',hMdl);
        end
        obj.ParseInfo.BuildInfo.setSuccess(true);
    catch E
        buildErr="";
        if~isempty(E.cause)

            buildErr=E.cause{1}.message;
        end
        obj.ParseInfo.BuildInfo.setErrors(buildErr);
        obj.ParseInfo.BuildInfo.setSuccess(false);
    end
end