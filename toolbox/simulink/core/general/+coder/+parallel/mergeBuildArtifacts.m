function mergeBuildArtifacts(subDir,rootMdlRefDir,sharedDir,mainObjFolder,...
    workerShared,topMdl,childMdl,pushParBuildArtifacts,targetType,...
    generateCodeOnly)




    import Simulink.internal.io.FileSystem;


    if isempty(subDir)
        return;
    end




    locVerifyManifest(subDir);


    if pushParBuildArtifacts==Simulink.ModelReference.internal.ModelRefPushParBuildArtifacts.ALL

        mastSharedUtils=fullfile(pwd,sharedDir);
        workerSharedUtils=fullfile(subDir,workerShared);


        lLinkObjChecksumPatch=...
        slprivate('merge_shared_utils',topMdl,workerSharedUtils,...
        mastSharedUtils,childMdl,pwd,false);
    end





    dirStruct=dir(subDir);
    workerModelDir=[childMdl,'_build'];
    secondaryOutputDirName='secondaryOutput';
    fullWorkerModelDir=fullfile(subDir,workerModelDir);

    wkrFiles=setdiff({dirStruct(:).name},...
    {'.','..',workerShared,workerModelDir,secondaryOutputDirName...
    ,'manifest.mat'});


    if~isempty(wkrFiles)
        isRTWTarget=strcmp(targetType,'RTW');
        for i=1:length(wkrFiles)
            wkrFile=fullfile(subDir,wkrFiles{i});
            mastFile=fullfile(pwd,wkrFiles{i});
            if isRTWTarget







                isSfunMexFile=~isempty(regexp(wkrFile,['.*_sfun\.',mexext,'$'],'once'));
                if isSfunMexFile&&isfile(mastFile)
                    continue;
                end
            end
            FileSystem.robustCopy(wkrFile,mastFile);
        end
    end

    buildDir=fullfile(pwd,rootMdlRefDir,childMdl);



    if exist(fullWorkerModelDir,'dir')
        retainOldFiles=(pushParBuildArtifacts==Simulink.ModelReference.internal.ModelRefPushParBuildArtifacts.UPDATED);
        if ispc



            if retainOldFiles
                copyArg='/E';
            else
                copyArg='/mir';
            end




            [robocopyStatus,robocopyResult]=system(['robocopy '...
            ,'"',fullWorkerModelDir,'"'...
            ,' '...
            ,'"',buildDir,'"'...
            ,' ',copyArg,' /np']);
            if(robocopyStatus>=8)
                DAStudio.error('RTW:utility:fileCopyFailed',fullWorkerModelDir,buildDir,['''robocopy'' reported: ',robocopyResult]);
            end
        else


            if retainOldFiles


                FileSystem.robustCopy(fullWorkerModelDir,buildDir);
                slprivate('removeDir',fullWorkerModelDir);
            else

                slprivate('removeDir',buildDir);
                FileSystem.robustMove(fullWorkerModelDir,buildDir);
            end
        end
    end

    locPollForFileExistence(fullfile(buildDir,'tmwinternal','binfo_mdlref.mat'));



    secondaryOutputDir=fullfile(subDir,secondaryOutputDirName);
    if isfolder(secondaryOutputDir)
        if strcmp(targetType,'SIM')

            codeGenFolder=Simulink.fileGenControl('get','CodeGenFolder');
            FileSystem.robustCopy(secondaryOutputDir,codeGenFolder);
        else



            cacheFolder=Simulink.fileGenControl('get','CacheFolder');
            dirContents=FileSystem.dirContents(secondaryOutputDir);
            for i=1:length(dirContents)
                wkrFile=fullfile(secondaryOutputDir,dirContents{i});
                mastFile=fullfile(cacheFolder,dirContents{i});
                isSfunMexFile=~isempty(regexp(wkrFile,['.*_sfun\.',mexext,'$'],'once'));
                if isSfunMexFile&&isfile(mastFile)







                    continue;
                end
                FileSystem.robustCopy(wkrFile,mastFile);
            end
        end
    end


    slprivate('removeDir',subDir);


    if pushParBuildArtifacts==Simulink.ModelReference.internal.ModelRefPushParBuildArtifacts.UPDATED
        return;
    end

    if strcmp(targetType,'SIM')


        compileInfoFolder=fullfile(buildDir,'mex');



        coder.make.internal.CompileInfoFile.updateLinkObjectChecksumCache...
        (compileInfoFolder);






        for i=1:length(lLinkObjChecksumPatch)
            coder.make.internal.CompileInfoFile.patchLinkObjChecksums...
            (compileInfoFolder,lLinkObjChecksumPatch{i});
        end
    end



    biMain=load(fullfile(buildDir,'buildInfo.mat'),'buildInfo');
    lReportInfo=detachReportInfo(biMain.buildInfo);
    if~isempty(lReportInfo)
        lReportInfo.updateCodeGenFolderAndBInfoMat(buildDir);
    end



    if isempty(mainObjFolder)



        mainObjFolderRelocated=buildDir;
    else
        workerAnchorDir=biMain.buildInfo.Settings.LocalAnchorDir;
        mainObjFolderRelocated=strrep(mainObjFolder,workerAnchorDir,pwd);
    end


    bi=load(fullfile(mainObjFolderRelocated,'buildInfo.mat'),...
    'buildInfo','buildOpts');


    if bi.buildOpts.MakefileBasedBuild

        startDir=pwd;


        postLoadUpdate(bi.buildInfo,mainObjFolderRelocated);

        coder.parallel.internal.tokenizeBuildInfoPaths(bi.buildInfo,startDir);




        compileInfoFile=fullfile(mainObjFolderRelocated,coder.make.internal.CompileInfoFile.getInfoFileName);
        if isfile(compileInfoFile)
            [~,incChecksumPatch]=coder.make.internal.getSourceFileChecksums(bi.buildInfo,[]);
            coder.make.internal.CompileInfoFile.patchIncludePathChecksums(mainObjFolderRelocated,incChecksumPatch);
        end


        coder.make.internal.saveBuildArtifacts(bi.buildInfo,bi.buildOpts,bi.buildInfo.detachReportInfo);



        if generateCodeOnly


            bi.buildOpts.generateCodeOnly=true;


            bi.buildOpts.ComponentsToBuild={bi.buildInfo.ComponentName};

            codebuild(bi.buildInfo,bi.buildOpts);
        end
    end
end

function missingFiles=locVerifyManifest(dirName,varargin)






    if nargin>1
        ignoreFileMissingError=varargin{1};
    else
        ignoreFileMissingError=false;
    end


    firstError=[];
    count=1;
    maxCount=100;

    done=false;
    while(~done)
        try
            load([dirName,filesep,'manifest.mat'],'manifest');
            done=true;
        catch exc
            if isempty(firstError)
                firstError=exc;
            end
            count=count+1;
            if count>=maxCount
                rethrow(firstError);
            end
            pause(0.1);
        end
    end


    count=1;
    maxCount=100;
    missingFiles=[];

    done=false;
    while(~done)
        dirInfo=dir(dirName);
        fileList={dirInfo(:).name};
        tmpNames=setdiff(manifest,fileList);
        if isempty(tmpNames)
            done=true;
        else
            count=count+1;
            if count>=maxCount
                missingFiles=tmpNames;
                if ignoreFileMissingError
                    return;
                else
                    DAStudio.error('Simulink:slbuild:parBuildVerifyManifestError',...
                    dirName,sprintf('%s\n',tmpNames{:}));
                end
            end
            pause(0.1);
        end
    end

    return;
end

function locPollForFileExistence(fname)


    fileExists=(exist(fname,'file')==2);
    idx=1;
    while(~fileExists&&(idx<100))
        fileExists=(exist(fname,'file')==2);
        if~fileExists
            idx=idx+1;
            pause(1);
        end
    end
end



