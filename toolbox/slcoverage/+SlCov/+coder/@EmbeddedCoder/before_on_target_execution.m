



function before_on_target_execution(this)

    try

        topModelName=this.getTopModelName();
        topModelH=get_param(topModelName,'Handle');
        isCvCmdCall=this.isCvCmdCall();
        coveng=cvi.TopModelCov.getInstance(topModelH);

        if isCvCmdCall

            if~isempty(coveng.covModelRefData)&&...
                ~isempty(coveng.covModelRefData.codeCovRecordingModels)
                refModelHandles=coveng.covModelRefData.codeCovRecordingModels.modelHandles;
                refModelNames=coveng.covModelRefData.codeCovRecordingModels.modelNames;
            else
                refModelHandles=[];
                refModelNames={};
            end
        else
            opts=SlCov.coder.EmbeddedCoder.getOptions(topModelName);
            if SlCov.CodeCovUtils.isAtomicSubsystem(topModelName)||...
                SlCov.CodeCovUtils.isReusableLibrarySubsystem(topModelName)

                opts.modelRefEnable=true;
                opts.covModelRefEnable='all';
            end
            [refModelNames,refModelHandles,topModelIsSILPIL,hasNormalModeRefModel]=...
            SlCov.coder.EmbeddedCoder.getRecordingModels(topModelName,opts);


            extraData=struct();
            if opts.covUseTimeInterval
                extraData.startRecTime=opts.covStartTime;
                extraData.stopRecTime=opts.covStopTime;
            end
        end


        [hookModelNames,hookCovModes]=SlCov.coder.EmbeddedCoder.getHookModelNames...
        (getOriginalComponentBuildInfo(this),isSilBuild(this),this.InTheLoopTypeForCoverage);

        [~,modelIdx,hookIdx]=intersect(refModelNames,hookModelNames);

        hookCovModes=hookCovModes(hookIdx);
        hookModelNames=hookModelNames(hookIdx);

        refModelTrInfo=cell(size(refModelNames));

        isFirstInstance=isempty(coveng)||...
        isempty(coveng.covModelRefData)||...
        ~isfield(coveng.covModelRefData.codeCovRecordingModels,'doneFirst')||...
        isempty(coveng.covModelRefData.codeCovRecordingModels.doneFirst);

        if isFirstInstance&&~isCvCmdCall



            if topModelIsSILPIL||~(opts.recordCoverage||hasNormalModeRefModel)



                if topModelIsSILPIL
                    topModelSimMode=lower(get_param(topModelName,'SimulationMode'));
                    if strcmp(topModelSimMode,SlCov.Utils.SIM_SIL_MODE_STR)
                        simMode=SlCov.CovMode.SIL;
                    else
                        assert(strcmp(topModelSimMode,SlCov.Utils.SIM_PIL_MODE_STR));
                        simMode=SlCov.CovMode.PIL;
                    end
                else
                    simMode=[];
                end
                cvi.TopModelCov.setupFromTopModel(topModelH,[],simMode);
                coveng=cvi.TopModelCov.getInstance(topModelH);


                coveng.covModelRefData.recordingModels=[];
                coveng.lastReportingModelH=[];
            else
                coveng=cvi.TopModelCov.getInstance(topModelH);
                if isempty(coveng)

                    cvi.TopModelCov.setupFromTopModel(topModelH);
                    coveng=cvi.TopModelCov.getInstance(topModelH);
                    coveng.covModelRefData.recordingModels=[];
                    coveng.lastReportingModelH=[];
                elseif isempty(coveng.covModelRefData)







                    coveng.covModelRefData=cv.ModelRefData;
                    coveng.covModelRefData.init(topModelH);
                    if~isempty(coveng.covModelRefData.recordingModels)&&isempty(coveng.lastReportingModelH)

                        coveng.covModelRefData.recordingModels=[];
                    end
                end
            end

            coveng.covModelRefData.codeCovRecordingModels=struct('modelHandles',{refModelHandles},...
            'modelNames',{refModelNames});
        end


        if isFirstInstance
            coveng.covModelRefData.codeCovRecordingModels.numExecutionPending=1;
            coveng.covModelRefData.codeCovRecordingModels.doneFirst=true;
            coveng.covModelRefData.codeCovRecordingModels.covModuleData=containers.Map;
            coveng.covModelRefData.codeCovRecordingModels.covModuleDataShared=containers.Map;
            coveng.covModelRefData.codeCovRecordingModels.DbRecordStatus=0;
        else
            coveng.covModelRefData.codeCovRecordingModels.numExecutionPending=...
            coveng.covModelRefData.codeCovRecordingModels.numExecutionPending+1;
        end

        hookModelData=coveng.covModelRefData.codeCovRecordingModels.covModuleData;
        hookSharedLibData=coveng.covModelRefData.codeCovRecordingModels.covModuleDataShared;

        if~cvi.TopModelCov.checkLicense(topModelH)
            coveng.covModelRefData.codeCovRecordingModels.hasLicenseError=true;
            return
        end

        if isFirstInstance
            coveng.covModelRefData.codeCovRecordingModels.hasLicenseError=false;



            wrapperModel=coder.connectivity.TopModelSILPIL.getWrapperModel(get_param(topModelH,'Name'));
            if~isempty(wrapperModel)
                menuSimModel=wrapperModel;
            else
                menuSimModel=topModelH;
            end
            coveng.isMenuSimulation=strcmp(get_param(menuSimModel,'CovUI_isMenuSimulation'),'on');



            coveng.embeddedCoderHookStatus={'running'};
        end


        if isempty(coveng.covModelRefData)
            recModels=[];
        else
            recModels=coveng.covModelRefData.recordingModels;
        end
        if isempty(recModels)
            recModels={''};
        end


        for iix=1:length(hookModelNames)

            ii=modelIdx(iix);
            modelH=refModelHandles(ii);
            modelName=hookModelNames{iix};

            if isCvCmdCall

                modelCovId=get_param(modelName,'CoverageId');
                testId=cv('get',modelCovId,'.activeTest');
                if testId==0







                    this.dispWarning({'Slvnv:codecoverage:CodeCoverageResultsProductionError',...
                    'Failed to retrieve the metrics list from the cvsim() command line. Falling back to the model settings.'});
                    testId=cvtest.create(modelCovId);
                    topModelCovId=cv('get',modelCovId,'.topModelcovId');
                    topTestId=cv('get',topModelCovId,'.activeTest');
                    if topTestId==0
                        testVar=cvtest(testId);
                        copyMetricsFromModel(testVar,get_param(topModelH,'Name'));
                    else
                        cvTest=cvtest(topTestId);
                        testVar=clone(cvTest,cvtest(testId));
                    end
                    activate(testVar,modelCovId);
                else
                    testVar=cvtest(testId);
                end
                opts=SlCov.coder.EmbeddedCoder.getOptionsFromTestVar(testVar);
                extraData=struct();
                if opts.covUseTimeInterval
                    extraData.startRecTime=opts.covStartTime;
                    extraData.stopRecTime=opts.covStopTime;
                end
            end

            modelCovMode=hookCovModes(iix);
            moduleName=SlCov.coder.EmbeddedCoder.buildModuleName(modelName,modelCovMode);
            [trDataFilePath,resFilePath]=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName);

            refModelTrInfo{ii}=[refModelTrInfo{ii};{moduleName,trDataFilePath,resFilePath}];
            internal.cxxfe.instrum.runtime.ResultHitsManager.startRecord(trDataFilePath,resFilePath,'',extraData);
            this.DbRecordStatus=this.DbRecordStatus+1;

            if modelH~=topModelH



                refModelHasNormal=any(strcmp(modelName,recModels));
                if~refModelHasNormal
                    set_param(modelName,'CoverageId',0);
                end
            end
        end

        if isFirstInstance
            coveng.getResultSettings;


            filterFileName='';
        else
            filterFileName=coveng.covModelRefData.codeCovRecordingModels.FilterFileName;
        end

        extractedFiles=containers.Map('KeyType','char','ValueType','any');
        extractedFileNames=containers.Map('KeyType','char','ValueType','any');

        firstPass=true;
        for iix=1:length(modelIdx)
            ii=modelIdx(iix);
            covMode=hookCovModes(iix);

            modelTrInfo=refModelTrInfo{ii};
            modelName=hookModelNames{iix};


            buildDir=RTW.getBuildDir(modelName);


            moduleName=modelTrInfo{1};
            trDataFilePath=modelTrInfo{2};
            resFilePath=modelTrInfo{3};
            traceabilityData=codeinstrum.internal.TraceabilityData(trDataFilePath,moduleName);

            if SlCov.CovMode.isSIL(covMode)
                covMode2=SlCov.CovMode.SIL;
            else
                covMode2=SlCov.CovMode.PIL;
            end





            symbolicName=traceabilityData.getSymbolicName('BUILD_DIR');
            if isempty(symbolicName)
                if ismember(covMode,[SlCov.CovMode.ModelRefSIL,SlCov.CovMode.ModelRefPIL])
                    currBuildDir=fullfile(buildDir.CodeGenFolder,buildDir.ModelRefRelativeBuildDir);
                else
                    currBuildDir=fullfile(buildDir.CodeGenFolder,buildDir.RelativeBuildDir);
                end
                currBuildDir=polyspace.internal.getAbsolutePath(currBuildDir);
            else
                currBuildDir=symbolicName.value;
            end

            currBuildDirForCmp=[currBuildDir,filesep];

            files=traceabilityData.getFilesInCurrentModule();
            modelFilesToExclude=cell(1,numel(files));
            idx=false(size(modelFilesToExclude));
            for jj=1:numel(files)
                if(files(jj).kind==internal.cxxfe.instrum.FileKind.SOURCE)&&...
                    ~strncmp(files(jj).path,currBuildDirForCmp,numel(currBuildDirForCmp))&&...
                    (files(jj).functions.Size()~=0)
                    modelFilesToExclude{jj}=files(jj).path;
                    idx(jj)=true;
                end
            end
            files(~idx)=[];
            modelFilesToExclude(~idx)=[];

            if~isempty(modelFilesToExclude)
                traceabilityData.setCurrentModule(moduleName,modelFilesToExclude);

                for kk=1:numel(modelFilesToExclude)
                    fullPath=modelFilesToExclude{kk};
                    chkSum=files(kk).structuralChecksum.toArray();
                    key=[SlCov.CovMode.toString(covMode2),newline,fullPath,newline,sprintf('%02X',chkSum)];
                    if extractedFiles.isKey(key)
                        fileInfo=extractedFiles(key);
                    else
                        fileInfo=struct('isSharedUtility',false,...
                        'fullPath',{{}},...
                        'trDataFilePath',{{}},...
                        'resFilePath',{{}},...
                        'origModuleName',{{}},...
                        'structuralChecksum',chkSum);

                        [~,fName,fExt]=fileparts(fullPath);
                        name=[fName,fExt];
                        if extractedFileNames.isKey(name)
                            extractedFileNames(name)=unique([extractedFileNames(name),{key}]);
                        else
                            extractedFileNames(name)={key};
                        end
                    end


                    fileInfo.trDataFilePath{end+1}=trDataFilePath;
                    fileInfo.resFilePath{end+1}=resFilePath;
                    fileInfo.origModuleName{end+1}=moduleName;
                    fileInfo.fullPath{end+1}=fullPath;
                    extractedFiles(key)=fileInfo;
                end
            end


            chkSum=traceabilityData.computeChecksum(true);
            testId=createTestData(coveng,modelName,covMode,chkSum,refModelHandles(ii));



            if firstPass
                firstPass=false;
                cvd=cvdata(testId);
                filterFileName=cvd.filter;
            end

            value=struct(...
            'modelName',modelName,...
            'covMode',covMode,...
            'modelFilesToExclude',{modelFilesToExclude},...
            'moduleName',moduleName,...
            'modelHandle',refModelHandles(ii)...
            );
            if~isKey(hookModelData,trDataFilePath)
                hookModelData(trDataFilePath)=value;
            end

        end

        if isFirstInstance
            coveng.covModelRefData.codeCovRecordingModels.extractedFiles=containers.Map;
            coveng.covModelRefData.codeCovRecordingModels.FilterFileName=filterFileName;
        end


        extractedFiles=i_createTestData(coveng,extractedFiles,extractedFileNames,filterFileName);
        if~isempty(extractedFiles)
            coveng.covModelRefData.codeCovRecordingModels.extractedFiles=containers.Map...
            ([coveng.covModelRefData.codeCovRecordingModels.extractedFiles.keys,extractedFiles.keys],...
            [coveng.covModelRefData.codeCovRecordingModels.extractedFiles.values,extractedFiles.values]);
        end




        sharedLibraryCoverage=SlCov.CodeCovUtils.isXILCoverageEnabled...
        (getTopModelName(this),getModelName(this),isSilBuild(this));

        if sharedLibraryCoverage

            if isSilBuild(this)
                currentCovMode=SlCov.CovMode.SIL;
            else
                currentCovMode=SlCov.CovMode.PIL;
            end

            numExistingSharedModules=hookSharedLibData.length;

            [extractedSharedFiles,extractedSharedFileNames]=...
            i_sharedFilesUpdate(this,currentCovMode,hookSharedLibData);

            numAdditionalSharedModules=hookSharedLibData.length-numExistingSharedModules;
            coveng.covModelRefData.codeCovRecordingModels.DbRecordStatus=coveng.covModelRefData.codeCovRecordingModels.DbRecordStatus+numAdditionalSharedModules;


            extractedSharedFiles=i_createTestData(coveng,extractedSharedFiles,extractedSharedFileNames,filterFileName);
            if~isempty(extractedSharedFiles)
                coveng.covModelRefData.codeCovRecordingModels.extractedFiles=containers.Map...
                ([coveng.covModelRefData.codeCovRecordingModels.extractedFiles.keys,extractedSharedFiles.keys],...
                [coveng.covModelRefData.codeCovRecordingModels.extractedFiles.values,extractedSharedFiles.values]);
            end
        end

    catch ME

        if this.DbRecordStatus>0
            try
                this.after_on_target_execution();
            catch
            end
        end
        rethrow(ME);
    end


    function testId=createTestData(coveng,name,mode,chkSum,modelH,isSharedUtility,filterFileName,fullPath)


        if nargin<8
            fullPath='';
        end
        if nargin<5
            modelH=[];
        end
        if nargin<6
            isSharedUtility=false;
        end
        if nargin<7
            filterFileName='';
        end


        modelcovVersionMangledName=SlCov.CoverageAPI.mangleModelcovName(name,mode);
        modelcovId=SlCov.CoverageAPI.findModelcovMangled(modelcovVersionMangledName);




        isCustomCodeFile=~isempty(fullPath)&&isempty(modelH)&&~isSharedUtility;
        badIdx=false(size(modelcovId));
        for ii=1:numel(modelcovId)
            cob=cv('get',modelcovId(ii),'.ownerBlock');
            if~strcmpi(coveng.ownerBlock,cob)
                badIdx(ii)=true;
                continue
            end
            if isCustomCodeFile

                ct=cv('get',modelcovId(ii),'.currentTest');
                if ct==0
                    continue
                end

                cvd=cvdata(ct);
                if~cvd.isCustomCode||isempty(cvd.codeCovData)
                    continue
                end

                files=cvd.codeCovData.CodeTr.getFilesInResults();
                if isempty(files)
                    continue
                end
                files([files.kind]~=internal.cxxfe.instrum.FileKind.SOURCE)=[];
                if~isempty(files)&&~ismember(fullPath,{files.path})
                    badIdx(ii)=true;
                end
            end
        end
        modelcovId(badIdx)=[];



        oldRootId=0;
        if isempty(modelcovId)
            modelcovId=SlCov.CoverageAPI.createModelcov(name,0,mode);
            cv('set',modelcovId,'.isScript',isempty(modelH));
        else

            for ii=1:numel(modelcovId)
                ct=cv('get',modelcovId(ii),'.currentTest');
                if ct~=0
                    oldRootId=cv('get',ct,'.linkNode.parent');
                    modelcovId=modelcovId(ii);
                    break
                end
            end
            modelcovId=modelcovId(1);
        end
        coveng.addScriptModelcovId(coveng.topModelH,modelcovId);




        testId=cv('get',modelcovId,'.activeTest');
        if testId==0
            testId=cvtest.create(modelcovId);


            topModelCovId=cv('get',modelcovId,'.topModelcovId');
            topTestId=cv('get',topModelCovId,'.activeTest');
            if topTestId==0
                newTest=cvtest(testId);
                copyMetricsFromModel(newTest,get_param(coveng.topModelH,'Name'));
            else
                cvTest=cvtest(topTestId);
                newTest=clone(cvTest,cvtest(testId));
            end
            activate(newTest,modelcovId);
        end

        if~isempty(modelH)



            cv('set',modelcovId,'.handle',modelH);
            cvi.TopModelCov.updateModelinfo(testId,modelH);
        end


        chkSum=typecast(chkSum,'uint32');
        rootId=cv('new','root','.topSlHandle',0,'.checksum',double(chkSum(:)'),'.modelcov',modelcovId);
        cv('set',modelcovId,'.activeRoot',rootId);

        if~isempty(modelH)

            oldModelCovId=get_param(modelH,'CoverageId');
            set_param(modelH,'CoverageId',modelcovId);

            cv('set',rootId,'.topSlHandle',modelH);



            if Simulink.internal.useFindSystemVariantsMatchFilter()
                allBlocks=find_system(modelH,'FollowLinks','on',...
                'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.activeVariants,...
                'DisableCoverage','off');
            else
                allBlocks=find_system(modelH,'FollowLinks','on',...
                'LookUnderMasks','all',...
                'DisableCoverage','off');
            end
            allCovIds=zeros(size(allBlocks));
            for idx=1:length(allBlocks)
                allCovIds(idx)=get_param(allBlocks(idx),'CoverageId');
            end



            clrSubsysPermsObj=cvprivate('changeSubsystemPermissions',modelH);

            cvi.TopModelCov.createSlsfHierarchy(modelH,false);


            initStateflowCodeCoverage(modelH);



            for idx=1:length(allBlocks)
                set_param(allBlocks(idx),'CoverageId',allCovIds(idx));
            end


            delete(clrSubsysPermsObj);



            if oldModelCovId~=0
                set_param(modelH,'CoverageId',oldModelCovId);
            end
        else

            topSlsfId=cv('new','slsfobj',1,'.origin','SRC_OBJ','.name',name,...
            '.modelcov',modelcovId,'.handle',0,'.refClass',0);



            if isSharedUtility
                origin='SRC_OBJ';
            else
                origin='SCRIPT_OBJ';
            end
            covId=cv('new','slsfobj',1,'.origin',origin,'.name',name,...
            '.modelcov',modelcovId,'.handle',0,'.refClass',0);
            cv('set',rootId,'.topSlsf',topSlsfId);
            cv('BlockAdoptChildren',topSlsfId,covId);
        end

        cvi.TopModelCov.setTestObjective(modelcovId,testId);



        cv('compareCheckSumForScript',modelcovId,oldRootId);


        rootId=cv('get',modelcovId,'.activeRoot');
        cv('set',rootId,'.filterApplied','');
        cv('set',testId,'.filterApplied','');
        if~isempty(filterFileName)
            cv('set',testId,'.covFilter',filterFileName);
        end



        if~isempty(modelH)
            cv('set',rootId,'.topSlHandle',modelH);
        else
            cv('set',rootId,'.topSlHandle',0);
        end

        cv('allocateModelCoverageData',modelcovId);

        coveng.initHarnessInfo(modelcovId,testId);


        function[extractedSharedFiles,extractedSharedFileNames]=...
            i_sharedFilesUpdate(this,covMode,hookSharedLibData)

            extractedSharedFiles=containers.Map('KeyType','char','ValueType','any');
            extractedSharedFileNames=containers.Map('KeyType','char','ValueType','any');


            lBuildInfoInstr=getInstrumentedComponentBuildInfo(this);
            lBuildInfoOriginal=getOriginalComponentBuildInfo(this);
            linkObjsOriginal=lBuildInfoOriginal.LinkObj;
            lOriginalBuildFolder=getOriginalBuildFolder(this);
            lInstrPartOfPath=this.InstrumentedObjectCodeFolder;



            includeIndirect=true;

            [sharedBuildInfos,~,lSharedLibPathsOriginalRelative,~,linkObjsInstr]=...
            coder.coverage.getSharedBuildInfos(lBuildInfoInstr,lInstrPartOfPath,includeIndirect);


            sharedBuildInfosOriginal=cell(size(sharedBuildInfos));
            for ii3=1:length(sharedBuildInfos)
                idx=strcmp({linkObjsOriginal.Name},linkObjsInstr(ii3).Name);
                sharedBuildInfosOriginal{ii3}=linkObjsOriginal(idx).BuildInfoHandle;
            end

            if SlCov.CodeCovUtils.isReusableLibrarySubsystem(this.getTopModelName())

                unitRLSBuildInfo=lBuildInfoInstr;
                [~,unitRLSBuildInfoPathOriginalRelative]=...
                coder.coverage.getOriginalPathsFromInstrumented(lBuildInfoInstr,...
                lInstrPartOfPath,{lOriginalBuildFolder});

                sharedBuildInfos=[unitRLSBuildInfo,sharedBuildInfos];
                lSharedLibPathsOriginalRelative=[unitRLSBuildInfoPathOriginalRelative,lSharedLibPathsOriginalRelative];
                sharedBuildInfosOriginal=[{lBuildInfoOriginal},sharedBuildInfosOriginal];
            end

            moduleNames=SlCov.coder.EmbeddedCoder.getSharedModuleName(covMode,lSharedLibPathsOriginalRelative);

            for ii3=1:length(sharedBuildInfos)

                moduleName=moduleNames{ii3};

                [trDataFilePath,resFilePath]=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName);

                lSharedLibPathOriginalRelative=lSharedLibPathsOriginalRelative{ii3};
                if isKey(hookSharedLibData,trDataFilePath)


                    continue
                end


                sharedFilesPaths=getSourceFiles(sharedBuildInfosOriginal{ii3},true,true);

                if isempty(sharedFilesPaths)
                    continue;
                end

                moduleName=moduleNames{ii3};

                value=struct(...
                'covMode',covMode,...
                'moduleName',moduleName,...
                'modulePath',lSharedLibPathOriginalRelative...
                );
                if~isKey(hookSharedLibData,trDataFilePath)
                    hookSharedLibData(trDataFilePath)=value;
                end

                internal.cxxfe.instrum.runtime.ResultHitsManager.startRecord(trDataFilePath,resFilePath);

                traceabilityData=codeinstrum.internal.TraceabilityData(trDataFilePath);

                traceabilityData.setSharedFilesAsCurrentModule(sharedFilesPaths,'');
                for jj=1:numel(sharedFilesPaths)
                    fullPath=sharedFilesPaths{jj};
                    f=traceabilityData.getFile(fullPath);
                    if f.functions.Size()==0

                        continue
                    end
                    chkSum=f.structuralChecksum.toArray();
                    key=[SlCov.CovMode.toString(covMode),newline,fullPath,newline,sprintf('%02X',chkSum)];
                    [~,fName,fExt]=fileparts(fullPath);
                    name=[fName,fExt];
                    if extractedSharedFileNames.isKey(name)
                        extractedSharedFileNames(name)=unique([extractedSharedFileNames(name),{key}]);
                    else
                        extractedSharedFileNames(name)={key};
                    end
                    fileInfo=struct('isSharedUtility',true,...
                    'fullPath',{{fullPath}},...
                    'trDataFilePath',{{trDataFilePath}},...
                    'resFilePath',{{resFilePath}},...
                    'origModuleName',{{moduleName}},...
                    'structuralChecksum',chkSum);

                    extractedSharedFiles(key)=fileInfo;
                end
            end


            function extractedFiles=i_createTestData(coveng,extractedFiles,extractedFileNames,filterFileName)

                keys=extractedFiles.keys();
                for ii=1:numel(keys)
                    key=keys{ii};
                    tokens=regexp(key,'\n','split');
                    covMode=SlCov.CovMode.fromString(tokens{1});
                    fullPath=tokens{2};

                    fileInfo=extractedFiles(key);


                    [~,fName,fExt]=fileparts(fullPath);
                    name=[fName,fExt];
                    if numel(extractedFileNames(name))>1
                        idx=find(strcmp(extractedFileNames(name),key),1,'first');
                        name=sprintf('%s (%d)',name,idx);
                    end

                    createTestData(coveng,name,covMode,fileInfo.structuralChecksum,[],fileInfo.isSharedUtility,filterFileName,fullPath);

                    fileInfo.name=name;
                    extractedFiles(key)=fileInfo;
                end


                function initStateflowCodeCoverage(modelH)
                    rt=sfroot;
                    m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',get_param(modelH,'Name'));
                    ch=m.find(...
                    '-isa','Stateflow.Chart','-or',...
                    '-isa','Stateflow.EMChart','-or',...
                    '-isa','Stateflow.LinkChart','-or',...
                    '-isa','Stateflow.StateTransitionTableChart','-or',...
                    '-isa','Stateflow.ReactiveTestingTableChart','-or',...
                    '-isa','Stateflow.TruthTableChart');
                    machineIdSet=containers.Map('KeyType','double','ValueType','any');

                    for jj=1:numel(ch)


                        [isActive,~]=Simulink.match.activeVariants(get_param(ch(jj).Path,'Handle'));
                        if~isActive
                            continue
                        end


                        cvChartSubsysId=get_param(ch(jj).Path,'CoverageId');
                        if~(cvChartSubsysId>0&&cv('ishandle',cvChartSubsysId))
                            continue
                        end

                        chartId=sfprivate('block2chart',ch(jj).Path);
                        instanceHandle=get_param(ch(jj).Path,'Handle');


                        machineId=sf('get',chartId,'chart.machine');
                        if~machineIdSet.isKey(machineId)
                            if sfObjNeedsUpdate(machineId,'machine','data')||...
                                sfObjNeedsUpdate(machineId,'machine','event')||...
                                sfObjNeedsUpdate(chartId,'chart','state')||...
                                sfObjNeedsUpdate(chartId,'chart','trans')
                                sf('Private','compute_session_independent_debugger_numbers',machineId);
                            end
                            machineIdSet(machineId)=true;
                        end


                        [cvStateIds,cvTransIds,~,cvChartId]=cvprivate('cvsf','InitChartInstance',chartId,instanceHandle);


                        if cvChartId~=0&&cv('ishandle',cvChartId)
                            cv('SetSlsfName',cvChartId,ch(jj).Name);
                            cvSfIds=[cvStateIds(:);cvTransIds(:)];
                            for kk=1:numel(cvSfIds)
                                if cvSfIds(kk)~=0&&cv('ishandle',cvSfIds(kk))

                                    cv('SetSlsfName',cvSfIds(kk),cvi.TopModelCov.getNameFromCvId(cvSfIds(kk)));
                                end
                            end
                        end
                    end


                    function status=sfObjNeedsUpdate(sfObjId,sfObjKind,sfChildKind)

                        status=false;
                        sfChildId=sf('find','all',[sfChildKind,'.',sfObjKind],sfObjId);
                        if numel(sfChildId)>1
                            sfNums=sf('get',sfChildId,[sfChildKind,'.number']);
                            status=all(sfNums==0);
                        end



