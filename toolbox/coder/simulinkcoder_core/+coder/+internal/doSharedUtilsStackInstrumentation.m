function lCodeInstrRegistry=doSharedUtilsStackInstrumentation(...
    lModelName,lBuildInfo,compileBuildOptsInstr,lMakeCommand,silPws,lCodeGenerationId)





    checksumFileName='stack_checksums.mat';
    lCodeInstrRegistry=[];
    sharedLinkObjs=[];

    [lHasSharedLib,~,~,sharedSrcLinkObject]=coder.internal.hasSharedLib(lBuildInfo);
    if lHasSharedLib&&~isempty(sharedSrcLinkObject)&&~isempty(sharedSrcLinkObject.BuildInfoHandle)
        sharedLinkObjs=sharedSrcLinkObject;
    end

    lBuildInfos=lBuildInfo.LinkObj;
    for i=1:length(lBuildInfos)
        shBuildInfo=lBuildInfos(i);
        if~strcmp(shBuildInfo.Group,'SHARED_SRC_LIB')&&...
            ~isempty(shBuildInfo)&&~isempty(shBuildInfo.BuildInfoHandle)
            sharedLinkObjs=[sharedLinkObjs,shBuildInfo];%#ok<AGROW>
        end
    end

    for i=1:length(sharedLinkObjs)
        sharedLinkObj=sharedLinkObjs(i);
        sharedBuildInfo=sharedLinkObj.BuildInfoHandle;
        cmpName=sharedLinkObj.Name;
        emptyCell=cell(1,0);
        lCodeInstrInfo=coder.internal.slCreateCodeInstrBuildArgs...
        (cmpName,silPws,emptyCell,true,cmpName,cmpName,emptyCell);

        srcFolder=coder.coverage.getOriginalPathsFromInstrumented(...
        sharedBuildInfo,lCodeInstrInfo.getInstrSrcFolder(),sharedLinkObj.Path);
        if~isfolder(srcFolder)
            continue;
        end

        instrFolder=fullfile(srcFolder,lCodeInstrInfo.getInstrSrcFolder());
        if~isfolder(instrFolder)
            continue;
        end

        [instrumentationUpToDate,newChecksums]=computeChecksum(...
        sharedBuildInfo,srcFolder,instrFolder,...
        lCodeGenerationId,checksumFileName);
        if instrumentationUpToDate
            continue;
        end

        allSourceFileSpecs=coder.internal.CodeInstrBuildArgs.getCodeInstrSourceFileTypes;
        foldersToInstrument={srcFolder};
        instrSrcFolder=lCodeInstrInfo.getInstrSrcFolder;
        instrObjFolder=lCodeInstrInfo.getInstrObjFolder;
        coder.internal.removeInstrumentedSource(...
        instrSrcFolder,instrObjFolder,foldersToInstrument);

        lReplacePaths=containers.Map('KeyType','char','ValueType','any');
        lReplacePaths('$(START_DIR)')=sharedBuildInfo.Settings.LocalAnchorDir;
        lUpdateModelLib=false;

        lCodeInstrInfo.rebaseInstrCode(sharedBuildInfo,lReplacePaths,lUpdateModelLib);

        if~isempty(instrSrcFolder)

            filesToInstrument=coder.internal.initializeInstrumentedSource...
            (instrSrcFolder,foldersToInstrument,...
            'FileSpecsToCopy',allSourceFileSpecs);



            coder.internal.updateBuildInfoWithInstrumentedFiles...
            (sharedBuildInfo,instrSrcFolder,foldersToInstrument,filesToInstrument);
        end


        lCodeInstrRegistry=coder.internal.doStackInstrumentation(...
        cmpName,lModelName,sharedBuildInfo,compileBuildOptsInstr,...
        lMakeCommand,srcFolder,instrFolder,foldersToInstrument,...
        instrSrcFolder);

        saveChecksums(instrFolder,newChecksums,...
        lCodeGenerationId,checksumFileName);

        coder.profile.CoderInstrumentationInfo.addComponentRegistry(instrFolder,lCodeInstrRegistry);
    end
end

function[instrumentationUpToDate,newChecksums]=computeChecksum(...
    buildInfo,srcFolder,instrFolder,lCodeGenerationId,checksumFileName)
    instrumentationUpToDate=false;

    sourceFiles=buildInfo.getSourceFiles(srcFolder,true);
    for i=1:length(sourceFiles)
        srcFile=sourceFiles{i};
        [directory,filename,ext]=fileparts(srcFile);
        if any(strcmp(directory,{srcFolder,instrFolder}))
            srcFile=fullfile(srcFolder,[filename,ext]);
            sourceFiles{i}=srcFile;
        end
    end
    checksums=coder.internal.utils.Checksum.calculate(sourceFiles);
    newChecksums=struct('sourceFiles',sourceFiles,'checksums',checksums);

    checksumFile=fullfile(instrFolder,checksumFileName);
    if isfile(checksumFile)
        res=load(checksumFile);
        instrumentationUpToDate=...
        res.CodeGenerationID==lCodeGenerationId&&isequal(res.Checksums,newChecksums);
    end
end

function saveChecksums(instrFolder,newChecksums,lCodeGenerationId,checksumFileName)

    Checksums=newChecksums;
    CodeGenerationID=lCodeGenerationId;
    save(fullfile(instrFolder,checksumFileName),'Checksums','CodeGenerationID');
end
