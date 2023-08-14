



function after_on_target_execution(this)

    try

        topModelName=this.getTopModelName();
        topModelH=get_param(topModelName,'Handle');
        coveng=cvi.TopModelCov.getInstance(topModelH);


        coveng.covModelRefData.codeCovRecordingModels.doneFirst=[];

        if isempty(coveng.covModelRefData)||...
            isempty(coveng.covModelRefData.codeCovRecordingModels)
            return
        end

        if isfield(coveng.covModelRefData.codeCovRecordingModels,'modelHandles')...
            &&~isempty(coveng.covModelRefData.codeCovRecordingModels.modelHandles)
            refModelNames=coveng.covModelRefData.codeCovRecordingModels.modelNames;
            refModelHandles=coveng.covModelRefData.codeCovRecordingModels.modelHandles;
        else
            refModelNames={};
            refModelHandles=[];
        end

        lIsSILBuild=isSilBuild(this);


        [hookModelNames,hookCovModes]=SlCov.coder.EmbeddedCoder.getHookModelNames...
        (getOriginalComponentBuildInfo(this),lIsSILBuild,this.InTheLoopTypeForCoverage);


        [~,modelIdx,hookIdx]=intersect(refModelNames,hookModelNames);

        hookCovModes=hookCovModes(hookIdx);
        hookModelNames=hookModelNames(hookIdx);


        coveng.covModelRefData.codeCovRecordingModels.numExecutionPending=...
        coveng.covModelRefData.codeCovRecordingModels.numExecutionPending-1;
        isLastInstance=coveng.covModelRefData.codeCovRecordingModels.numExecutionPending==0;


        for iix=1:length(modelIdx)
            modelName=hookModelNames{iix};
            moduleName=SlCov.coder.EmbeddedCoder.buildModuleName(modelName,hookCovModes(iix));
            [~,resHitsFile]=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName);

            if this.DbRecordStatus>0
                internal.cxxfe.instrum.runtime.ResultHitsManager.stopRecord(resHitsFile);
                this.DbRecordStatus=this.DbRecordStatus-1;
            end
        end

        if~isLastInstance
            return
        end

        hookSharedLibData=coveng.covModelRefData.codeCovRecordingModels.covModuleDataShared;
        dbFilePaths=hookSharedLibData.keys;


        for i=1:length(dbFilePaths)
            dbFilePath=dbFilePaths{i};
            moduleData=hookSharedLibData(dbFilePath);
            moduleName=moduleData.moduleName;
            [~,resHitsFile]=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName);
            if coveng.covModelRefData.codeCovRecordingModels.DbRecordStatus>0
                internal.cxxfe.instrum.runtime.ResultHitsManager.stopRecord(resHitsFile);
                coveng.covModelRefData.codeCovRecordingModels.DbRecordStatus=coveng.covModelRefData.codeCovRecordingModels.DbRecordStatus-1;
            end
        end

        if coveng.covModelRefData.codeCovRecordingModels.hasLicenseError
            return
        end


        isATS=SlCov.CodeCovUtils.isAtomicSubsystem(topModelName);


        instrumOptions=this.getInstrumOptions();
        metricNames={'Decision','Condition','MCDC','RelationalBoundary','Statement','FunEntry','FunExit','FunCall'};
        idx=true(size(metricNames));
        idx(1)=instrumOptions.Decision;
        idx(2)=instrumOptions.Condition;
        idx(3)=instrumOptions.MCDC;
        idx(4)=instrumOptions.RelationalBoundary;
        idx(5:end)=instrumOptions.Statement;
        metricNames(~idx)=[];

        currRes=coveng.getDataResult();


        allResObjs=SlCov.results.CodeCovData.empty();
        isCvData=isa(currRes,'cvdata');


        hookModelData=coveng.covModelRefData.codeCovRecordingModels.covModuleData;


        reachableFunSigs=[];

        dbFilePaths=hookModelData.keys;
        for ii=1:length(dbFilePaths)
            dbFilePath=dbFilePaths{ii};
            modelData=hookModelData(dbFilePath);
            modelName=modelData.modelName;
            moduleName=modelData.moduleName;
            [~,resHitsFile]=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName);
            covMode=modelData.covMode;
            filesToExclude=modelData.modelFilesToExclude;
            modelHandle=modelData.modelHandle;


            covdata=iGetCovData(modelName,covMode,isCvData,currRes);
            if isempty(covdata)
                continue
            end


            buildDir=RTW.getBuildDir(modelName);


            if ismember(covMode,[SlCov.CovMode.ModelRefSIL,SlCov.CovMode.ModelRefPIL])
                currBuildDir=fullfile(buildDir.CodeGenFolder,buildDir.ModelRefRelativeBuildDir);
            else
                currBuildDir=fullfile(buildDir.CodeGenFolder,buildDir.RelativeBuildDir);
            end
            htmlDir=fullfile(currBuildDir,'html');


            traceInfoMat=fullfile(htmlDir,'traceInfo.mat');





            traceInfoBuilder=get_param(modelName,'CoderTraceInfo');
            if(isempty(traceInfoBuilder)||isempty(traceInfoBuilder.files))&&...
                (get_param(modelName,'IsERTTarget')=="on")
                traceInfoBuilder=coder.trace.TraceInfoBuilder(modelName);
                traceInfoBuilder.buildDir=currBuildDir;
                traceInfoBuilder.repositoryDir=fullfile(currBuildDir,'tmwinternal');
                if~traceInfoBuilder.load()
                    traceInfoBuilder=[];
                elseif lIsSILBuild


                    traceInfoBuilder.buildDir=currBuildDir;
                    traceInfoBuilder.repositoryDir=fullfile(currBuildDir,'tmwinternal');
                end
            end


            traceabilityData=codeinstrum.internal.TraceabilityData(dbFilePath);
            traceabilityData.setCurrentModule(moduleName,filesToExclude);
            traceabilityData.close();
            traceabilityData.SourceKind=internal.cxxfe.instrum.SourceKind.ECoder;


            atsEntryPointFunSigs=[];
            if isATS
                buildInfoFile=fullfile(currBuildDir,'buildInfo.mat');
                if isfile(buildInfoFile)
                    bInfo=load(buildInfoFile);
                    [~,entryPointsInfo]=...
                    coder.connectivity.XILSubsystemUtils.getEntryPointsForAtomicSusbystemCoverage(...
                    topModelName,modelName,bInfo.buildInfo);
                    if~isempty(entryPointsInfo)
                        atsEntryPointFunSigs=traceabilityData.extractReachableFunSignatures(entryPointsInfo);
                    end
                end
            end


            resObj=SlCov.results.CodeCovData(...
            'traceabilityData',traceabilityData,...
            'resHitsFile',resHitsFile,...
            'name',modelName,...
            'metricNames',metricNames,...
            'entryPointFunSigs',atsEntryPointFunSigs,...
            'mcdcMode',covdata.modelinfo.mcdcMode...
            );
            resObj.Mode=covMode;

            resObj.mapModelToCode(traceInfoMat,traceInfoBuilder,covdata);


            covdata.codeCovData=resObj;


            if~isempty(atsEntryPointFunSigs)
                resObj.resetFilters();




                reachableFunSigs=atsEntryPointFunSigs;
            end


            cvi.TopModelCov.setUpFiltering(topModelH,covdata);

            allResObjs=[allResObjs;covdata.codeCovData];%#ok<AGROW>
        end


        extractedFiles=coveng.covModelRefData.codeCovRecordingModels.extractedFiles;
        keys=extractedFiles.keys();
        for ii=1:numel(keys)
            key=keys{ii};
            tokens=regexp(key,'\n','split');
            covMode=SlCov.CovMode.fromString(tokens{1});
            fileInfo=extractedFiles(key);
            name=fileInfo.name;


            covdata=iGetCovData(name,covMode,isCvData,currRes);
            if isempty(covdata)
                continue
            end

            if fileInfo.isSharedUtility
                sourceKind=internal.cxxfe.instrum.SourceKind.SharedUtil;
            else
                sourceKind=internal.cxxfe.instrum.SourceKind.CustomCode;
            end



            for jj=1:numel(fileInfo.trDataFilePath)
                trDataFilePath=fileInfo.trDataFilePath{jj};
                resFilePath=fileInfo.resFilePath{jj};
                fullPath=fileInfo.fullPath{jj};
                traceabilityData=codeinstrum.internal.TraceabilityData(trDataFilePath);
                traceabilityData.setSharedFilesAsCurrentModule({fullPath},name);
                traceabilityData.close()
                traceabilityData.SourceKind=sourceKind;
                resObj=SlCov.results.CodeCovData(...
                'traceabilityData',traceabilityData,...
                'resHitsFile',resFilePath,...
                'name',name,...
                'metricNames',metricNames,...
                'mcdcMode',covdata.modelinfo.mcdcMode,...
                'origModuleName',fileInfo.origModuleName{jj}...
                );

                res=resObj.getAggregatedResults();
                stats=res.getDeepMetricStats(resObj.CodeTr.Root,internal.cxxfe.instrum.MetricKind.FUN_ENTRY);
                if stats.numCovered>0
                    break
                end
            end

            resObj.Mode=covMode;


            covdata.codeCovData=resObj;


            cvi.TopModelCov.setUpFiltering(topModelH,covdata);



            if isATS&&~isempty(reachableFunSigs)
                functions=resObj.CodeTr.getFunctions();
                if all(~ismember({functions.signature},reachableFunSigs))
                    cv('set',cv('get',covdata.rootId,'.modelcov'),'.currentTest',0);
                end
            end

            allResObjs=[allResObjs;covdata.codeCovData];%#ok<AGROW>
        end


        try
            genAnnotations(this,allResObjs);
        catch MeAnnot
            this.dispWarning({'Slvnv:codecoverage:CodeViewExtractionError',MeAnnot.message});
        end

        prevStatus=coveng.embeddedCoderHookStatus;
        coveng.embeddedCoderHookStatus=[];
        if isempty(coveng.lastReportingModelH)

            modelH=coveng.topModelH;
            coveng.setLastReporting(modelH);
            if get_param(modelH,'IsStoppingInFastRestart')
                cvi.TopModelCov.modelPause(modelH);
            else
                cvi.TopModelCov.modelTerm(modelH);
            end
            coveng.setLastReporting([]);
        elseif strcmp(prevStatus{1},'last_running')


            if strcmp(prevStatus{2},'modelTerm')
                cvi.TopModelCov.modelTerm(coveng.lastReportingModelH);
            else
                cvi.TopModelCov.modelFastRestart(coveng.lastReportingModelH,true);
            end
        end

        this.dispInfo(['### ',getString(message('CoderCoverage:AllTools:CompletedCoverage'))]);

    catch ME

        this.dispWarning({'Slvnv:codecoverage:CodeCoverageResultsProductionError',ME.message});
        rethrow(ME);
    end


    function covdata=iGetCovData(name,covMode,isCvData,currRes)
        if isCvData
            covdata=currRes;
        else
            covdata=currRes.get(name,covMode);
        end


        function genAnnotations(this,allResObjs)

            codeGenFolder=this.getCodeGenFolder();
            modelName=this.getModelName();



            componentObjDirs=fullfile(this.getOriginalBuildFolder(),this.InstrumentedObjectCodeFolder);
            componentObjDirs=strrep(componentObjDirs,codeGenFolder,'');
            if componentObjDirs(1)==filesep
                componentObjDirs=componentObjDirs(2:end);
            end
            componentObjDirs={componentObjDirs};


            buildDir=RTW.getBuildDir(modelName);
            componentObjDirs=...
            cat(2,componentObjDirs,...
            {fullfile(buildDir.SharedUtilsTgtDir,this.InstrumentedObjectCodeFolder)});



            refModelsList=find_mdlrefs(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            for ii=1:numel(refModelsList)
                if~strcmp(refModelsList{ii},modelName)
                    buildDir=RTW.getBuildDir(refModelsList{ii});
                    componentObjDirs=...
                    cat(2,componentObjDirs,...
                    {fullfile(buildDir.ModelRefRelativeBuildDir,this.InstrumentedObjectCodeFolder)});
                end
            end

            [componentHtmlFolders,allSrcFiles]=this.getHtmlFolders();

            annotations=SlCov.coder.EmbeddedCoderAnnotations(allResObjs,codeGenFolder,componentObjDirs);

            this.writeCoverageXml(componentHtmlFolders,allSrcFiles,annotations,true);


