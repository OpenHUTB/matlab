function loadTraceInfo(h)




    matFile=fullfile(h.BuildDirRoot,h.getTraceInfoFileName);
    datFile=[matFile,'cd'];
    if~exist(matFile,'file')||...
        (~exist(datFile,'file')&&slfeature('AsyncSaveTraceRegistry')>0)
        DAStudio.error('RTW:traceInfo:traceInfoFileNotFound',h.BuildDir,h.Model);
    end
    tinfo=load(matFile);
    if isempty(tinfo)||~isfield(tinfo,'infoStruct')
        DAStudio.error('RTW:traceInfo:traceInfoFileNotValid',h.BuildDir);
    end

    tdata=struct();
    if exist(datFile,'file')
        tdata=rtwprivate('rtwctags_registry','load',datFile);
        fldNames=fieldnames(tdata);
        for k=1:numel(fldNames)
            tinfo.infoStruct.(fldNames{k})=tdata.(fldNames{k});
        end
    end


    if~strcmp(tinfo.infoStruct.params.Name,h.Model)
        DAStudio.error('RTW:traceInfo:notValidBuildDir',h.BuildDir,h.Model);
    end



    h.clear(true);

    h.Registry=tinfo.infoStruct.traceInfo;
    h.RegistrySidMap=tinfo.infoStruct.traceInfoSidMap;
    h.inlineTraceIsMerged=tinfo.infoStruct.inlineTraceIsMerged;
    try
        h.GeneratedFiles=tinfo.infoStruct.generatedFiles;
        h.ModelVersionAtBuild=tinfo.infoStruct.params.ModelVersion;
        h.ModelDirtyAtBuild=tinfo.infoStruct.params.Dirty;
        h.ModelFileNameAtBuild=tinfo.infoStruct.params.FileName;
        h.TimeStamp=tinfo.infoStruct.params.TimeStamp;
        h.ReducedBlocks=tinfo.infoStruct.reducedBlocks;
        h.InsertedBlocks=tinfo.infoStruct.insertedBlocks;
        h.SourceSystem=tinfo.infoStruct.sourceSystem;
        h.ModifiedTimeStamp=tinfo.infoStruct.params.ModifiedTimeStamp;
        if isfield(tinfo.infoStruct,'systemMap')
            h.SystemMap=tinfo.infoStruct.systemMap;
        end
        if isfield(tinfo.infoStruct.params,'CodeReuseDiagnostics')
            h.ReuseInfo=tinfo.infoStruct.params.CodeReuseDiagnostics;
        end
        if isfield(tinfo.infoStruct,'tmpModel')
            h.TmpModel=tinfo.infoStruct.tmpModel;
        end


        h.IsTestHarnes=tinfo.infoStruct.isTestHarness;
        h.HarnessOwner=tinfo.infoStruct.harness.harnessOwner;
        h.HarnessName=tinfo.infoStruct.harness.harnessName;
        h.OwnerFileName=tinfo.infoStruct.harness.ownerFileName;

    catch
        MSLDiagnostic('RTW:traceInfo:traceInfoFileNotValid',h.BuildDir).reportAsWarning;
    end


