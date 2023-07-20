function parBDir=setupBuildDir(mdlName,rootMdlRefDir,...
    rootMdlRefSimDir,parMdlRefCopyDir,...
    simTargetSharedObjs,...
    sharedDir,sharedSimDir,workerShared,...
    clientFileGenCfg,targetType)




    parBDir.mdlName=mdlName;
    parBDir.subDir=fullfile(pwd,parMdlRefCopyDir,mdlName);
    parBDir.subFlagDir=fullfile(pwd,parMdlRefCopyDir,'flag',mdlName);
    parBDir.subSharedDir=fullfile(parBDir.subDir,workerShared);
    parBDir.savePath=path;
    parBDir.mdlRefRootDir=rootMdlRefDir;
    parBDir.rootMdlRefSimDir=rootMdlRefSimDir;
    parBDir.sharedDir=sharedDir;
    parBDir.sharedSimDir=sharedSimDir;

    parBDir.tmpDir=locCreateWorkerTmpDir();
    parBDir.useSeparateCacheAndCodeGen=...
    ~strcmp(clientFileGenCfg.CacheFolder,clientFileGenCfg.CodeGenFolder);

    if parBDir.useSeparateCacheAndCodeGen
        [cacheDir,codeGenDir]=locCreateWkrCacheAndCodeGenDir(parBDir.tmpDir);
        if strcmp(targetType,'SIM')
            parBDir.primaryOutputDir=cacheDir;
            parBDir.secondaryOutputDir=codeGenDir;
        else
            parBDir.primaryOutputDir=codeGenDir;
            parBDir.secondaryOutputDir=cacheDir;
        end
    else

        cacheDir=parBDir.tmpDir;
        codeGenDir=cacheDir;
        parBDir.primaryOutputDir=codeGenDir;
    end




    if~isempty(simTargetSharedObjs)
        workerSharedUtilsFolder=fullfile(parBDir.primaryOutputDir,parBDir.sharedDir);
        if~isfolder(workerSharedUtilsFolder)
            [status,result]=mkdir(workerSharedUtilsFolder);
            assert(status==1,'mkdir failure in update_model_reference_targets (1): %s',result);
        end
        fileName='simTargetObjsInMasterFolder.txt';
        fileName=fullfile(workerSharedUtilsFolder,fileName);
        fid=fopen(fileName,'w');
        fwrite(fid,join(string(simTargetSharedObjs),newline));
        fclose(fid);
    end


    addpath(pwd);

    cd(parBDir.primaryOutputDir);












    Simulink.fileGenControl('setParallelBuildInProgress',...
    'CacheFolder',cacheDir,...
    'CodeGenFolder',codeGenDir,...
    'keepPreviousPath',true);
end

function tmpDir=locCreateWorkerTmpDir()

    maxAttempts=100;
    for i=1:maxAttempts
        [systemTmpDir,tmpDirName]=fileparts(tempname);



        tmpDirName=tmpDirName(2:10);
        tmpDir=fullfile(systemTmpDir,tmpDirName);

        if~isfolder(tmpDir)

            [status,msg,msgID]=mkdir(tmpDir);
            assert(status==1,'Failed to create temporary worker folder: %s %s',msgID,msg);
            return
        end
    end

    assert(false,"Maximum number of attempts exceeded creating a temporary folder for parallel worker");
end

function[cacheDir,codeGenDir]=locCreateWkrCacheAndCodeGenDir(tmpDir)

    errorMsg='Failed to create temporary worker folder: %s %s';
    cacheDir=fullfile(tmpDir,'c');
    [status,msg,msgID]=mkdir(cacheDir);
    assert(status==1,errorMsg,msgID,msg);

    codeGenDir=fullfile(tmpDir,'cg');
    [status,msg,msgID]=mkdir(codeGenDir);
    assert(status==1,errorMsg,msgID,msg);
end


