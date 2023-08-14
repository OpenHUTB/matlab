function infoStruct=saveTraceInfo(h)




    if~exist(h.BuildDir,'dir')
        DAStudio.error('RTW:traceInfo:buildDirNotFound',h.BuildDir,h.Model);
    end

    filename=fullfile(h.BuildDirRoot,h.getTraceInfoFileName);
    fpath=fileparts(filename);
    if~exist(fpath,'dir')
        rtwprivate('rtw_create_directory_path',fpath);
    end

    infoData=struct();


    infoData.traceInfo=h.Registry;
    infoData.inlineTraceIsMerged=h.inlineTraceIsMerged;
    infoData.generatedFiles=h.GeneratedFiles;

    if slfeature('AsyncSaveTraceRegistry')>0

        binFile=[filename,'cd'];
        if~exist(binFile,'file')
            rtwprivate('rtwctags_registry','save',binFile,infoData);
        end
    end

    infoStruct.traceInfoSidMap=h.RegistrySidMap;
    infoStruct.reducedBlocks=h.ReducedBlocks;
    infoStruct.insertedBlocks=h.InsertedBlocks;
    infoStruct.sourceSystem=h.SourceSystem;
    infoStruct.tmpModel=h.TmpModel;
    infoStruct.systemMap=h.SystemMap;


    infoStruct.params=[];
    infoStruct.params.Name=h.Model;
    infoStruct.params.ModelVersion=h.ModelVersionAtBuild;
    infoStruct.params.Dirty=h.ModelDirtyAtBuild;
    infoStruct.params.FileName=h.ModelFileNameAtBuild;
    infoStruct.params.TimeStamp=h.TimeStamp;
    infoStruct.params.ModifiedTimeStamp=h.ModifiedTimeStamp;
    infoStruct.params.CodeReuseDiagnostics=h.ReuseInfo;


    infoStruct.isTestHarness=h.IsTestHarnes;
    infoStruct.harness.harnessOwner=h.HarnessOwner;
    infoStruct.harness.harnessName=h.HarnessName;
    infoStruct.harness.ownerFileName=h.OwnerFileName;

    flds=fieldnames(infoData);
    if slfeature('AsyncSaveTraceRegistry')>0

        if~exist(filename,'file')
            save(filename,'infoStruct');
        end

        for k=1:numel(flds)
            infoStruct.(flds{k})=infoData.(flds{k});
        end

    else
        for k=1:numel(flds)
            infoStruct.(flds{k})=infoData.(flds{k});
        end
        if~exist(filename,'file')
            save(filename,'infoStruct');
        end
    end
