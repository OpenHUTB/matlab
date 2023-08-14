function[outputFiles,buildDir]=buildRacTarget(modelFile,options,~)

    isDeploymentBuild=Simulink.isRaccelDeploymentBuild;
    resetDeploymentBuild=onCleanup(@()Simulink.isRaccelDeploymentBuild(isDeploymentBuild));
    Simulink.isRaccelDeploymentBuild(true);


    bVerbose=false;
    if(options.Verbose)
        bVerbose=true;
    end

    curDir=pwd;




    load_simulink;


    [modelDir,modelName,~]=fileparts(modelFile);


    isCurDirOnPath=locIsDirOnPath(curDir);
    isModelDirOnPath=locIsDirOnPath(modelDir);
    isModelLoaded=bdIsLoaded(modelName);
    origCacheFolder=Simulink.fileGenControl('getinternalvalue','CacheFolder');
    origCodegenFolder=Simulink.fileGenControl('getinternalvalue','CodeGenFolder');
    c_pre=onCleanup(@()locCleanupPre(modelName,...
    curDir,isCurDirOnPath,...
    modelDir,isModelDirOnPath,...
    isModelLoaded,...
    origCacheFolder,origCodegenFolder));


    if(~isCurDirOnPath)
        addpath(curDir);
    end


    if(~isModelDirOnPath)
        addpath(modelDir);
    end



    if~exist(modelFile,'file')
        error('Building rapid accelerator target for mcc failed because model file could not be found');
    end


    folders=Simulink.filegen.internal.FolderConfiguration(modelName,true,false);
    buildDir=folders.RapidAccelerator.absolutePath('ModelCode');


    if(~isModelLoaded)
        load_system(modelName);
    end

    modelLockState=get_param(modelName,"Lock");
    isModelLocked=matlab.lang.OnOffSwitchState(modelLockState);
    if isModelLocked
        outputFiles={};
        buildDir='';
        return;
    end

    locBuildOnceLoaded(modelName,buildDir,bVerbose);


    outputFilesStruct=dir(fullfile(buildDir,'**/*'));




    filesNeededForBuildButNotForMCC={'buildInfo.mat'};
    outputFileNames={outputFilesStruct.name};
    [~,indicesOfFilesToKeep]=setdiff(outputFileNames,filesNeededForBuildButNotForMCC);
    outputFilesStruct=outputFilesStruct(indicesOfFilesToKeep);

    outputFilesCell=struct2cell(outputFilesStruct);
    idx=vertcat(outputFilesCell{5,:})==0;
    o_filtered=outputFilesCell(:,idx);
    outputFiles=cellfun(@(x,y)fullfile(x,y),o_filtered(2,:),o_filtered(1,:),'Uniform',false);
end

function locBuildOnceLoaded(modelName,buildDir,bVerbose)


    origVerbose=get_param(modelName,'AccelVerboseBuild');

    c_post=onCleanup(@()locCleanupPost(modelName,...
    origVerbose));



    if(bVerbose)
        locSetAccelVerboseBuild(modelName,'on');
    end




    fh=@Simulink.BlockDiagram.buildRapidAcceleratorTarget;
    cpp_feval_wrapper(fh,modelName);


    cleanout_slprj_for_deployment(buildDir,modelName);
end

function isOnPath=locIsDirOnPath(myDir)
    pathCell=regexp(path,pathsep,'split');
    if ispc
        isOnPath=any(strcmpi(myDir,pathCell));
    else
        isOnPath=any(strcmp(myDir,pathCell));
    end
end

function locCleanupPre(model,...
    curDir,isCurDirOnPath,...
    modelDir,isModelDirOnPath,...
    isModelLoaded,...
    origCacheFolder,origCodegenFolder)

    if(~isModelLoaded)
        close_system(model,0);
    end

    Simulink.fileGenControl('set',...
    'CacheFolder',origCacheFolder,...
    'CodeGenFolder',origCodegenFolder);

    if(~isCurDirOnPath&&locIsDirOnPath(curDir))
        rmpath(curDir);
    end
    if(~isModelDirOnPath&&locIsDirOnPath(modelDir))
        rmpath(modelDir);
    end
end

function locCleanupPost(model,...
    origVerboseSetting)

    locSetAccelVerboseBuild(model,origVerboseSetting);
end

function locSetAccelVerboseBuild(model,value)
    cs=getActiveConfigSet(model);
    if isa(cs,'Simulink.ConfigSetRef');
        cs=cs.getRefConfigSet;
    end
    set_param(cs,'AccelVerboseBuild',value);
end
