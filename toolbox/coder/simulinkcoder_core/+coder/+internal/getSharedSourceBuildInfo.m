function[sharedSrcBuildInfo,buildInfoSharedIsUpToDate]=getSharedSourceBuildInfo...
    (modelBuildInfo,...
    lAnchorFolder,...
    lSharedSourcesFolder,...
    lSharedObjectFolder,...
    buildName,...
    src_exts)








    buildInfoSharedFileName=fullfile...
    (lAnchorFolder,lSharedObjectFolder,'buildInfo.mat');
    sharedSrcBuildInfo=coder.internal.loadSharedSourceBuildInfo...
    (lAnchorFolder,fileparts(buildInfoSharedFileName));

    buildInfoSharedIsUpToDate=true;


    lSharedUtilsSrcFolder=fullfile(lAnchorFolder,lSharedSourcesFolder);
    onFileSystemSrcs=coder.internal.getFilesMatchingExtension...
    (src_exts,lSharedUtilsSrcFolder);


    if~isempty(sharedSrcBuildInfo)
        srcFilesSharedFromBuildInfo=...
        getSourceFiles(sharedSrcBuildInfo,false,false);
    else
        srcFilesSharedFromBuildInfo={};
    end


    removedSrcs=setdiff(srcFilesSharedFromBuildInfo,onFileSystemSrcs);
    if~isempty(removedSrcs)
        i_removeSourceFiles(sharedSrcBuildInfo,removedSrcs);
        buildInfoSharedIsUpToDate=false;
    end


    srcFilesSharedFromBuildInfo=setdiff(srcFilesSharedFromBuildInfo,removedSrcs);


    newSrcs=setdiff(onFileSystemSrcs,srcFilesSharedFromBuildInfo);


    if isempty(srcFilesSharedFromBuildInfo)&&~isempty(newSrcs)
        sharedSrcBuildInfo=i_constructNewBuildInfo...
        (lSharedObjectFolder,lSharedSourcesFolder,...
        modelBuildInfo,lAnchorFolder,buildName);


        coder.internal.createSharedUtilsProjFile(lAnchorFolder,lSharedObjectFolder,...
        sharedSrcBuildInfo.ModelName);
    end

    if~isempty(newSrcs)
        buildInfoSharedIsUpToDate=false;


        loc_addNewSourceFiles(sharedSrcBuildInfo,lSharedSourcesFolder,newSrcs);
    end


    function loc_addNewSourceFiles(sharedSrcBuildInfo,lSharedSourcesFolder,...
        newSrcs)


        addSourceFiles(sharedSrcBuildInfo,newSrcs,...
        fullfile('$(START_DIR)',lSharedSourcesFolder));



        function sharedSrcBuildInfo=i_constructNewBuildInfo...
            (lSharedObjectFolder,lSharedSourcesFolder,...
            modelBuildInfo,lAnchorFolder,buildName)

            sharedSrcBuildInfo=RTW.BuildInfo;
            sharedSrcBuildInfo.ModelName=buildName;
            sharedSrcBuildInfo.Settings.LocalAnchorDir=lAnchorFolder;
            componentBuildFolder=fullfile(lAnchorFolder,lSharedObjectFolder);
            if~isfolder(componentBuildFolder)
                mkdir(componentBuildFolder)
            end
            sharedSrcBuildInfo.ComponentBuildFolder=componentBuildFolder;



            setStartDir(sharedSrcBuildInfo,lAnchorFolder);


            if~isempty(modelBuildInfo)
                [~,lTgtFcnLib]=findTMFToken(modelBuildInfo,'|>TGT_FCN_LIB<|');

                coder.make.internal.initTMFTokens...
                (sharedSrcBuildInfo,...
                'TgtFcnLib',lTgtFcnLib,...
                'ModelName',buildName,...
                'MakefileName',[sharedSrcBuildInfo.ModelName,'.mk']);
            else
                coder.make.internal.initTMFTokens...
                (sharedSrcBuildInfo,...
                'ModelName',sharedSrcBuildInfo.ModelName,...
                'MakefileName',[sharedSrcBuildInfo.ModelName,'.mk']);
            end


            sharedSrcBuildInfo.CompilerRequirements=inheritRequirementsFromDonor...
            (sharedSrcBuildInfo.CompilerRequirementsDirect,modelBuildInfo.CompilerRequirementsDirect);


            lRelativePathToAnchor='';
            tmpSharedBinaryDir=lSharedObjectFolder;
            while~isempty(tmpSharedBinaryDir)
                tmpSharedBinaryDir=fileparts(tmpSharedBinaryDir);
                lRelativePathToAnchor=fullfile(lRelativePathToAnchor,'..');
            end


            coder.make.internal.initBuildInfoBuildArgs(sharedSrcBuildInfo,...
            'RelativePathToAnchor',lRelativePathToAnchor);


            addIncludePaths(sharedSrcBuildInfo,...
            fullfile('$(START_DIR)',lSharedSourcesFolder));



            if(~isempty(modelBuildInfo))
                sharedSrcBuildInfo.Settings.TargetInfo=modelBuildInfo.Settings.TargetInfo;
            end


            function i_removeSourceFiles(sharedSrcBuildInfo,srcsToRemove)
                srcs={sharedSrcBuildInfo.Src.Files.FileName};
                [~,removeIdx]=intersect(srcs,srcsToRemove);
                sharedSrcBuildInfo.Src.Files(removeIdx)=[];

