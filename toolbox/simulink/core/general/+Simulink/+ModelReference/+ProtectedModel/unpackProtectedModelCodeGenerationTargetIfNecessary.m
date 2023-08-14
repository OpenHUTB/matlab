function unpackProtectedModelCodeGenerationTargetIfNecessary(...
    protectedModelFile,topMdl,buildArgs,compileCodeIfNecessary,...
    lXilInfo,lGenerateCodeOnly,lVerbose)



    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;


    [opts,fullName]=getOptions(protectedModelFile);

    if~supportsCodeGen(opts)

        DAStudio.error('Simulink:protectedModel:ProtectedModelUnsupportedModeRTW',...
        opts.modelName);
    end



    locSetCurrentTarget(topMdl,opts);

    rootRTWDir=getRTWBuildDir();
    buildDirs=RTW.getBuildDir(opts.modelName);



    if strcmp(opts.isERTTarget(),'on')
        Creator.doLicenseCheckEC();
    else

        Creator.doLicenseCheckRTW();
    end





    isFromCurrentRelease=...
    slInternal('isProtectedModelFromThisSimulinkVersion',fullName);
    if~isFromCurrentRelease
        loc_validateCrossReleaseLicenseAndSTF(fullName,opts.modelName,topMdl);
    end


    rootTargetDir=fullfile(rootRTWDir,buildDirs.ModelRefRelativeRootTgtDir);

    try

        runCallback(fullName,'PreAccess','CODEGEN');


        year=RelationshipTarget.getRelationshipYear();
        currentTarget=getCurrentTarget(opts.modelName);

        if~isFromCurrentRelease





            compileInfoHandler=coder.internal.xrel.transformation.CompileInfoHandler;
            compileInfoHandler.backupCompileInfoMATFilesForSLXP(opts.modelName,opts.subModels,opts.codeInterface);
        end


        writeRelationship(fullName,rootRTWDir,currentTarget,year);


        infoYear=RelationshipInfoForCodegen.getRelationshipYear();
        infoTarget=constructTargetRelationshipName('infoForCodeGen',currentTarget);
        writeRelationship(fullName,rootRTWDir,infoTarget,infoYear);


        if opts.hasCustomRTWFiles()

            year=RelationshipCustom.getRelationshipYear();
            custom=constructTargetRelationshipName('custom',currentTarget);
            writeRelationship(fullName,rootRTWDir,custom,year);
        end


        topMdlIsERT=loc_topMdlIsERT(topMdl);




        existingSharedCode=coder.internal.xrel.getOriginalExistingSharedCodeParam(topMdl);
        if~isFromCurrentRelease


            if topMdlIsERT
                coder.internal.xrel.validateExistingSharedCodeForProtectedModel(...
                topMdl,...
                existingSharedCode,...
                rootRTWDir,...
                opts.modelName,...
                opts.codeInterface);
            end
        end






        existingSharedCodeSet=~isempty(existingSharedCode);

        year=RelationshipTargetSharedUtils.getRelationshipYear();
        isERTXRelProt=topMdlIsERT&&~isFromCurrentRelease;
        isNonERTXRelProt=~topMdlIsERT&&~isFromCurrentRelease;
        if isERTXRelProt
            xrelType=CrossReleaseWorkflowType.ERT;
        elseif isNonERTXRelProt
            xrelType=CrossReleaseWorkflowType.NonERT;
        else
            xrelType=CrossReleaseWorkflowType.None;
        end
        extractSharedUtils(fullName,rootTargetDir,currentTarget,'rtwsharedutils',...
        year,topMdl,rootRTWDir,buildDirs,false,xrelType);

        if existingSharedCodeSet







            lResolvedExistingSharedCode=coder.internal.xrel.get_ExistingSharedCode_param(topMdl);
            lSharedUtilsFolder=fullfile(rootRTWDir,buildDirs.SharedUtilsTgtDir);
            coder.internal.xrel.mergeExistingSharedCode(lResolvedExistingSharedCode,lSharedUtilsFolder,{});
        else
            lResolvedExistingSharedCode='';
        end


        unpackCodegenReportIfNecessary(protectedModelFile);

        if~isFromCurrentRelease







            coder.internal.xrel.transformation.updateBuildArtifactsForProtectedModel(...
            opts.modelName,...
            opts.subModels,...
            opts.codeInterface,...
            lResolvedExistingSharedCode,...
            topMdl,...
            opts.slprjVersion);
        end


        if compileCodeIfNecessary
            locDoCompile(opts,fullName,lXilInfo,lGenerateCodeOnly,lVerbose,topMdl,...
            buildArgs.BaDefaultCompInfo);
        end
    catch me
        if strcmp(me.identifier,'Simulink:protectedModel:ProtectedModelWrongPassword')
            myException=getWrongPasswordDetailedException(opts.modelName,'RTW');
            myException.throw;
        else
            rethrow(me);
        end
    end
end


function[subModelBuildFolders,subModelTargetTypes]=...
    locUpdateBuildInfo(opts,fullName,buildInfoStruct,lIsSilAndPws,...
    lDefaultCompInfo)



    [subModelBuildFolders,subModelTargetTypes]=locUpdateSubModelBuildInfos...
    (opts.modelName,opts.subModels,opts.codeInterface);



    if~slInternal('isProtectedModelFromThisSimulinkVersion',fullName)
        modelVersion=slInternal('getProtectedModelVersion',fullName);
        sharedUtilsBuildinfoTransformer=...
        coder.internal.xrel.transformation.SharedUtilsBuildInfoTransformer;
        sharedUtilsBuildinfoTransformer.updateSharedUtilitiesBuildInfoIfNecessary(...
        buildInfoStruct,...
        subModelBuildFolders,...
        modelVersion);
    end


    Simulink.ModelReference.ProtectedModel.protectedInstrumentationStage...
    (opts.modelName,opts.subModels,subModelBuildFolders,...
    subModelTargetTypes,lIsSilAndPws,lDefaultCompInfo);

end



function locDoCompile(opts,fullName,lXilInfo,lGenerateCodeOnly,lVerbose,topMdl,...
    lDefaultCompInfo)




    [lInstrObjFolder,lIsSilAndPws]=loc_getInstrObjFolder(opts.modelName,...
    opts.codeInterface,lXilInfo.IsSil);

    skipBuild=false;
    sourceCodeAvailable=...
    Simulink.ModelReference.ProtectedModel.packageSourceCode(opts);
    if sourceCodeAvailable
        if~isempty(opts.callbackMgr)
            cbCG=opts.callbackMgr.getCallback('Build','CODEGEN');
            if~isempty(cbCG)

                Simulink.ModelReference.ProtectedModel.runCallback...
                (fullName,'Build','CODEGEN');
                skipBuild=cbCG.getOverrideBuild();
            end
        end
    end


    buildInfoStruct=loc_getBuildInfoForTopProtectedModel(opts.modelName,opts.codeInterface);

    isMakefileBasedBuild=buildInfoStruct.buildOpts.MakefileBasedBuild;
    generateMakefile=true;
    if isMakefileBasedBuild
        generateMakefile=strcmp(get_param(topMdl,'GenerateMakefile'),'on');
    end

    needBuildInfoUpdate=~skipBuild&&...
    (~lGenerateCodeOnly||(lGenerateCodeOnly&&generateMakefile));

    if needBuildInfoUpdate
        [subModelBuildFolders,subModelTargetTypes]=...
        locUpdateBuildInfo(opts,fullName,buildInfoStruct,lIsSilAndPws,...
        lDefaultCompInfo);

        if sourceCodeAvailable

            Simulink.ModelReference.ProtectedModel.protectedCompile...
            (opts.modelName,opts.subModels,subModelBuildFolders,subModelTargetTypes,...
            lXilInfo,lGenerateCodeOnly,lInstrObjFolder,lVerbose);
        else
            if needBuildInfoUpdate


                loc_buildSharedUtilitiesLib(lInstrObjFolder,opts.codeInterface,...
                opts.modelName);
            end
        end
    end
end


function buildInfoStruct=loc_getBuildInfoForTopProtectedModel(modelName,codeInterface)
    rootDirBase=Simulink.ModelReference.ProtectedModel.getRTWBuildDir();
    buildDirs=RTW.getBuildDir(modelName);


    tgt='RTW';
    if strcmp(codeInterface,'Top model')
        tgt='NONE';
    end


    if strcmp(tgt,'NONE')
        buildDir=fullfile(rootDirBase,buildDirs.RelativeBuildDir);
    else
        buildDir=fullfile(rootDirBase,buildDirs.ModelRefRelativeRootTgtDir,modelName);
    end


    buildInfoStruct=Simulink.ModelReference.common.loadBuildInfo(buildDir);

end


function locSetCurrentTarget(topMdl,opts)
    import Simulink.ModelReference.ProtectedModel.*;



    stfFile=strtrim(coder.internal.getCachedAccelOriginalSTF(topMdl,false));
    [~,target,~]=fileparts(stfFile);

    lOriginalTarget=Simulink.ModelReference.ProtectedModel.CurrentTarget.get(opts.modelName);



    setCurrentTarget(opts.modelName,target);


    if~strcmp(lOriginalTarget,target)
        Simulink.filegen.internal.FolderConfiguration.updateCache(opts.modelName);
    end
end




function[subModelBuildFolders,subModelTargetTypes]=...
    locUpdateSubModelBuildInfos(modelName,subModels,codeInterface)

    subModelBuildFolders=cell(size(subModels));
    subModelTargetTypes=cell(size(subModels));

    rootDirBase=Simulink.ModelReference.ProtectedModel.getRTWBuildDir();
    buildDirs=RTW.getBuildDir(modelName);

    for i=1:length(subModels)
        subModel=subModels{i};


        tgt='RTW';
        if strcmp(subModel,modelName)&&strcmp(codeInterface,'Top model')
            tgt='NONE';
        end


        if strcmp(tgt,'NONE')
            buildDir=fullfile(rootDirBase,buildDirs.RelativeBuildDir);
        else
            buildDir=fullfile(rootDirBase,buildDirs.ModelRefRelativeRootTgtDir,subModel);
        end


        buildInfoStruct=Simulink.ModelReference.common.loadBuildInfo(buildDir);


        binfoMATFile=coderprivate.getBinfoMATFileAndCodeName(buildDir);
        loadConfigSet=false;
        infoStruct=coder.internal.infoMATFileMgr...
        ('loadPostBuild','binfo',subModel,tgt,binfoMATFile,loadConfigSet);


        buildInfoStruct=Simulink.ModelReference.ProtectedModel.updateBuildInfo...
        (buildInfoStruct,...
        modelName,...
        subModel,...
        tgt,...
        infoStruct.relativePathToAnchor);


        save(fullfile(buildDir,'buildInfo.mat'),'-struct','buildInfoStruct');

        subModelBuildFolders{i}=buildDir;
        subModelTargetTypes{i}=tgt;
    end
end


function[tgt,infoStruct,buildInfoPath,buildInfoStruct]=...
loc_getBuildInfoAndInfoStruct...
    (modelName,codeInterface,lInstrObjFolder,rootDirBase)
    buildDirs=RTW.getBuildDir(modelName);


    if strcmp(codeInterface,'Top model')
        tgt='NONE';
        buildDir=fullfile(rootDirBase,...
        buildDirs.RelativeBuildDir);
    else
        tgt='RTW';
        buildDir=fullfile(rootDirBase,...
        buildDirs.ModelRefRelativeRootTgtDir,modelName);
    end


    infoStruct=coder.internal.infoMATFileMgr('load','binfo',...
    modelName,tgt);


    buildInfoPath=fullfile(buildDir,lInstrObjFolder);
    buildInfoStruct=Simulink.ModelReference.common.loadBuildInfo(buildInfoPath);

end


function[lInstrObjFolder,lIsSilAndPws]=...
    loc_getInstrObjFolder(lModelName,codeInterface,lIsSil)


    if strcmp(codeInterface,'Top model')
        tgt='NONE';
    else
        tgt='RTW';
    end


    infoStruct=coder.internal.infoMATFileMgr('load','binfo',...
    lModelName,...
    tgt);
    isPWSEnabled=infoStruct.IsPortableWordSizesEnabled;
    lIsSilAndPws=lIsSil&&isPWSEnabled;


    lCodeCoverageSpec=[];
    modelsWithProfiling=[];
    isExecutionProfilingEnabledInTop=false;
    usePWSSpec=isPWSEnabled&&lIsSil;

    lCodeInstrInfo=coder.internal.slCreateCodeInstrBuildArgs...
    (lModelName,...
    usePWSSpec,...
    lCodeCoverageSpec,...
    isExecutionProfilingEnabledInTop,...
    modelsWithProfiling,...
    infoStruct.modelRefs,...
    infoStruct.protectedModelRefs);

    if isempty(lCodeInstrInfo)
        lInstrObjFolder='';
    else
        lInstrObjFolder=getInstrObjFolder(lCodeInstrInfo);
    end

end

function loc_buildSharedUtilitiesLib(lInstrObjFolder,codeInterface,modelName)

    rootDirBase=Simulink.ModelReference.ProtectedModel.getRTWBuildDir();

    [~,~,~,buildInfoStruct]=loc_getBuildInfoAndInfoStruct...
    (modelName,codeInterface,lInstrObjFolder,rootDirBase);
    lBuildInfo=buildInfoStruct.buildInfo;
    [lHasSharedLib,lSharedLibPath]=coder.internal.hasSharedLib(lBuildInfo);

    if lHasSharedLib
        lSharedLibBuildFolder=fullfile(rootDirBase,lSharedLibPath);
        codebuild(lSharedLibBuildFolder);
    end
end

function topMdlIsERT=loc_topMdlIsERT(topMdl)






    modelRTWGenSettings=get_param(topMdl,'RTWGenSettings');
    accIsERTTarget='off';
    if~isempty(modelRTWGenSettings)&&...
        isfield(modelRTWGenSettings,'AccelIsERTTarget')

        accIsERTTarget=modelRTWGenSettings.AccelIsERTTarget;
    end
    topMdlIsERT=strcmp(get_param(topMdl,'IsERTTarget'),'on')||...
    strcmp(accIsERTTarget,'on');
end

function loc_validateCrossReleaseLicenseAndSTF(fullName,modelName,topMdl)


    modelVersion=slInternal('getProtectedModelVersion',fullName);
    if(builtin('_license_checkout','RTW_Embedded_Coder','quiet')~=0)
        DAStudio.error(...
        'Simulink:protectedModel:protectedModelSimulinkVersionMismatchNoEcoder',...
        fullName,...
        modelVersion);
    end



    stfFile=strtrim(coder.internal.getCachedAccelOriginalSTF(topMdl,false));
    tempCS=Simulink.ConfigSet;
    set_param(tempCS,'SystemTargetFile',stfFile);
    coder.internal.xrel.validateSystemTargetFileForProtectedModel(...
    tempCS,...
    modelName,...
    simulink_version(modelVersion));
end


