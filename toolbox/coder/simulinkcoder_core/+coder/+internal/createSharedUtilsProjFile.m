function createSharedUtilsProjFile(compileAnchorDir,lSharedObjectFolder,sharedSrcModelName)





    lSharedObjectFolderFull=fullfile(compileAnchorDir,lSharedObjectFolder);

    if~isfile(fullfile(lSharedObjectFolderFull,'rtw_proj.tmw'))

        if~isfolder(lSharedObjectFolderFull)
            [status,result]=mkdir(lSharedObjectFolderFull);
            assert(status==1,'mkdir failure in CREATESHAREDUTILSPROJFILE: %s',result);
        end




        lTemplateMakefile='';
        coder.internal.generateRtwProjFile...
        (sharedSrcModelName,lTemplateMakefile,...
        lSharedObjectFolderFull,pwd,'..');
    end


