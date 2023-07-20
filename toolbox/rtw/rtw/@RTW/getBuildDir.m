function info=getBuildDir(model,field)



















    validateattributes(model,{'string','char'},{'scalartext'});
    model=convertStringsToChars(model);
    if nargin>1
        field=convertStringsToChars(field);
    end

    if(exist(model,'file')~=4)
        DAStudio.error('RTW:utility:invalidModel',model);
    end



    returnParameter=(nargin>=2);

    to_resolve=model;
    if bdIsLoaded(model)
        f=get_param(model,'FileName');
        if~isempty(f)
            to_resolve=f;
        end
    end

    [isProtected,fullName]=slInternal('getReferencedModelFileInformation',to_resolve);
    if bdIsLoaded(model)||isempty(fullName)||~isProtected

        mdlsToClose=locLoadModels(model);

        reader=coder.internal.stf.FileReader.getInstance(get_param(model,'SystemTargetFile'));
        reader.parseSettings(model);
        genSet=reader.GenSettings;

        folders=Simulink.filegen.internal.FolderConfiguration(model);

        info.BuildDirectory=folders.CodeGeneration.absolutePath('ModelCode');
        info.CacheFolder=folders.Simulation.Root;
        info.CodeGenFolder=folders.CodeGeneration.Root;
        info.RelativeBuildDir=folders.CodeGeneration.ModelCode;
        info.BuildDirSuffix=genSet.BuildDirSuffix;
        info.ModelRefRelativeRootSimDir=folders.Simulation.TargetRoot;
        info.ModelRefRelativeRootTgtDir=folders.CodeGeneration.TargetRoot;
        info.ModelRefRelativeBuildDir=folders.CodeGeneration.ModelReferenceCode;
        info.ModelRefRelativeSimDir=folders.Simulation.ModelReferenceCode;
        info.ModelRefRelativeHdlDir=folders.HDLGeneration.ModelReferenceCode;
        info.ModelRefDirSuffix=genSet.ModelReferenceDirSuffix;
        info.SharedUtilsSimDir=folders.Simulation.SharedUtilityCode;
        info.SharedUtilsTgtDir=folders.CodeGeneration.SharedUtilityCode;

        locCloseModels(mdlsToClose);
    else



        opts=slInternal('getProtectedModelExtraInformation',fullName);
        info=opts.getBuildDirFromModel(model);



        fileGenCfg=Simulink.fileGenControl('getConfig');

        info.BuildDirectory=fullfile(fileGenCfg.CodeGenFolder,...
        info.RelativeBuildDir);
        info.CacheFolder=fileGenCfg.CacheFolder;
        info.CodeGenFolder=fileGenCfg.CodeGenFolder;
    end

    if returnParameter
        info=info.(field);
    end

















    function mdlsToClose=locLoadModels(model)

        mdlsToClose={};


        openMdls=find_system('SearchDepth',0,'type','block_diagram');

        if~ismember(model,openMdls)
            load_system(model);
            allOpenMdls=find_system('SearchDepth',0,'type','block_diagram');
            mdlsToClose=setdiff(allOpenMdls,openMdls);
        end















        function locCloseModels(modelsToClose)

            num=length(modelsToClose);
            for i=1:num
                close_system(modelsToClose{i},0);
            end




