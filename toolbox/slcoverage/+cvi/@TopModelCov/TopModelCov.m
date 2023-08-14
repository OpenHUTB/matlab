



classdef TopModelCov<handle
    properties
covModelRefData
scriptDataMap
scriptNumToCvIdMap
lastReportingModelH
oldModelcovIds
topModelH
resultSettings
multiInstanceNormaModeSf
coderCov
slccCov
embeddedCoderHookStatus
lastCovData
        ownerModel=''
        unitUnderTestName=''
        harnessModel=''
        ownerBlock=''
        ownerType=''
        keepHarnessCvData=false
        forceTopModelResultsRemoval=false;
        restorableParams=[]
        autoscaleInFastRestart=false
        lastFastRestartData=[]
        isSimulationOutput=[]
        isMenuSimulation=false
        activeData=[]
        simscapeCov=[]
    end
    properties(Dependent)
modelUnderTest
    end
    methods
        function activeModel=get.modelUnderTest(coveng)
            if~isempty(coveng.ownerModel)&&coveng.keepHarnessCvData
                activeModel=coveng.ownerModel;
            else
                activeModel=coveng.topModelH;
            end
        end
    end
    methods
        function this=TopModelCov(modelH)
            this.topModelH=modelH;
        end
        addModelcov(this,modelH)
        addScriptModelcovId(this,modelH,modelcovId)
        scriptStart(this,modelH)
        allIds=getAllModelcovIds(this)
        modelCovIds=getModelCovIdsForReporting(this)
        res=isLastReporting(this,modelH)
        setLastReporting(this,modelH)
        getResultSettings(this)
        genResults(this)
        res=getDataResult(this)
        checkCumDataConsistency(this)
        res=isCvCmdCall(this)
        [testId,rootSlHandle]=initTest(coveng,modelH,modelcovId)
        allocateCovData(coveng,modelH)
        updateResults(coveng,testId)
        genCovResults(coveng,res,varargin)
        makeReport(coveng,res,cumRes,outputDir)
        setupHarnessInfo(coveng)
        initHarnessInfo(this,modelcovId,testId)
        addMdlRef(coveng,modelName,isAccel)
        getReducedBlocks(coveng,modelH,testId)
        updateScriptinfo(coveng,testId,handle,cvScriptId)

    end
    methods(Static)
        [coveng,modelcovId]=getInstance(modelH)
        deleteInstance(modelH)
        [coveng,modelcovId]=setup(modelH,topModelcovId,isAccel)
        term(modelcovId);
        setupFromTopModel(modelH,varargin)
        termFromTopModel(topModelH)
        modelInit(modelH,hiddenSubSys,forCodeCov,isObserver)
        cvScriptId=scriptInit(scriptId,scriptNum,chartId,instanceHandle)
        modelStart(modelH,isAccelMdlRef)
        postModelStartFromTop(modelH)
        modelFastRestart(modelH,fromModelPause)
        modelPause(modelH)
        modelTerm(modelH)
        modelClose(modelH)
        modelCleanup(modelH)
        setIsSimulationOutput(modelH,isSimulationOutput)
        covTotal=genResultsForSigbuilder(modelH,sigbuilderH,covdata)
        genResultsForRunAll(modelH,designStudyLabel)
        covTotal=genResultsForMultiSim(modelH,covdata,tags)
        [status,msgId]=checkLicense(modelH)
        createSlsfHierarchy(modelCovId,hiddenSubSys)
        createSlsfSubHierarchy(subSysH)
        blktypes=getSupportedBlockTypes
        res=isDVBlock(blkH)
        ssid=getSID(cvid)
        handle=findChildHandle(parentH,cvid)
        handle=getRootHandle(rootId)
        pH=getParentHandle(handle)
        name=getNameFromCvId(cvid)
        newRootId=createRoot(modelcovId,rootSlHandle)
        res=compareRoots(root1,root2)
        res=checkMetricConsistency(newRoot,oldRoot,changeBoth)
        [res,diff]=compareChecksum(newRoot,oldRoot)
        res=checkSlsfHandle(cvId,handle)
        filterApplied=getFilterApplied(rootId)
        [statusChanged,datedFilterName]=setUpFiltering(topModelH,cvd,rootId)
        setModelCovFilterApplied(modelCovId,filterAppliedStruct)
        resetFilter(rootId,cvd,beforeSim)
        storeSFVariantFilterRules(modelcovId,testId)
        [selectors,isVarTrans]=createSFVariantFilterRuleSelectors(modelcovId,activeRoot,testId)
        selectors=createStartupVariantFilterRuleSelectors(modelH,testId)
        startupVarFilterData=createStartupVariantFilterData(modelH,testId)
        storeStartupVariantFilterRules(modelcovId,testId)
        out=isStartupVariantCoverageSupported()
        fullCovPath=checkCovPath(modelName,covPath)
        covPath=makeCovPath(rootSlHandle)
        [filtObjs,condObjs,decObjs]=getFilteredMetricsBySubProp(filter,cvid,ssid)
        res=getRunningTotal(modelCovObjs,prev)
        cumData(modelH,cmd,cvd)
        res=hasCumData(modelH)
        res=isLastReportingModel(modelH)
        ccInfo=getCustomCodeInfo(topModelH)
        fileName=getUniqueFileName(dirName,fileName)
        fullFileName=saveData(cvd,outputDir,dataFileName,incFileName)
        outputDir=checkOutputDir(outputDir,errorReporting)
        res=updateModelName(modelcovId)
        [status,msg]=updateModelHandles(modelId,modelName,updateAllRoots)
        checkModelConistency(modelId)
        [cvd,ccvd]=cvResults(modelName,varargin)
        depth=getBlockDepth(handle)
        eliminated=isModelEliminated(modelH)
        updatedRefIds=removeEliminatedModels(topModelcovId)
        handleFilterCallback(topModelH,filterFileName,ssid,action,codeCovInfo,explorerGeneratedReport,idx,outcomeIdx,metricName,descr)
        handleFilter(topModelH,filterFileName,ssid,action,codeCovInfo,explorerGeneratedReport)
        restoreCoverageEnable(modelH)
        unsetModelContentsCoverageIds(modelH)
        cleanupFastRestart(modelH)
        newRootId=moveHarnessTest(modelcovId,ownerModel,cvd)
        canHarnessMapBackToOwner=isRootMergePossible(modelcovId,currentRootId)
        [matchingSlsfObj,hasCandidates]=findMatchingPossibleRoot(topRootId,blockNameToFind,checksumToFind)
        moveBlockTypes(origModel,newModel)
        cloneBlockTypes(dstModelcovId,srcModelcovId)
        onlyAutoscale=updateAutoscalingResults(covEng,isInModelPause)
        modelCovClear(topModelH)
        setIsMenuSimulation(modelH,isMenuSimulation)
        modelobject=getObject(ssid)
        storeHarnessInfo(harnessInfo,modelcovId,testId)
        covHarnessInfo=getCovHarnessInfo(harnessInfo)
        out=compareChecksumsAndMetricSettings(cvd1,cvd2)
        checksum=derivedDataIncompatibleChecksum
    end
    methods(Static)

        function[filterObj,filter]=getFilterObj(topModelH,~)
            try
                get_param(topModelH,'handle');
            catch %#ok<CTCH>
                try
                    open_system(topModelH);
                    topModelH=get_param(topModelH,'handle');
                catch %#ok<CTCH>
                    error(message('Slvnv:simcoverage:cvdisplay:LoadError',topModelH));
                end
            end

            topModelname=get_param(topModelH,'name');
            filterObj=cvi.ResultsExplorer.ResultsExplorer.findExistingDlg(topModelname);

            if isempty(filterObj)
                filterObj=cvi.ResultsExplorer.ResultsExplorer.getInstance(topModelname,[]);
                filter=filterObj.filterEditor;
            else
                filter=filterObj.filterEditor;
            end

        end

        function closeResultsExplorer(modelHandle)
            if exist('cvi.ResultsExplorer.ResultsExplorer','class')
                cvi.ResultsExplorer.ResultsExplorer.close(modelHandle);
                cvi.FilterExplorer.FilterExplorer.closeModelCallback(modelHandle)
            end
        end

        function closeAllResultsExplorer()
            if exist('cvi.ResultsExplorer.ResultsExplorer','class')
                cvi.ResultsExplorer.ResultsExplorer.closeAll();
            end
        end

        function filter=showFilterEditor(filterObj)

            if isa(filterObj,'cvi.ResultsExplorer.ResultsExplorer')
                filter=filterObj.filterEditor;
                filterObj.showFilter();
            else
                filter=filterObj;
                filter.show;
            end
        end

        function updatedRefIds=removeStaleRefenceIds
            allCvIds=cv('find','all','.isa',cv('get','default','modelcov.isa'));
            for idx=1:numel(allCvIds)
                topModelcovId=allCvIds(idx);
                refModelcovIds=cv('get',topModelcovId,'.refModelcovIds');
                updatedRefIds=refModelcovIds;
                refModelcovIds(updatedRefIds==topModelcovId)=[];

                for currModelcovId=refModelcovIds(:)'
                    if~cv('ishandle',currModelcovId)||...
                        ~isequal(cv('get',currModelcovId,'.isa'),cv('get','default','modelcov.isa'))
                        updatedRefIds(updatedRefIds==currModelcovId)=[];
                    end
                end
                cv('set',topModelcovId,'.refModelcovIds',updatedRefIds);
            end
        end


        function res=isTopMostModel(modelH)


            res=false;
            modelCovId=get_param(modelH,'CoverageId');
            if modelCovId==0||~cv('ishandle',modelCovId)
                return;
            end

            topModelCovId=cv('get',modelCovId,'.topModelcovId');

            res=topModelCovId==modelCovId;
        end


        function setTestObjective(modelcovId,testId)
            activeRootId=cv('get',modelcovId,'.activeRoot');

            if testId==0

                [~,allTOMetricNames]=cvi.MetricRegistry.getAllMetricNames;
                for i=1:numel(allTOMetricNames)
                    cmn=allTOMetricNames{i};
                    metricenumValue=cvi.MetricRegistry.getEnum(cmn);
                    metricdataIds(metricenumValue)=cv('new','metricdata','.metricName',cmn,'.metricenumValue',metricenumValue);%#ok<AGROW>
                end
                cv('set',activeRootId,'.testobjectives',metricdataIds);
            else
                cv('set',activeRootId,'.testobjectives',cv('get',testId,'.testobjectives'));
            end
        end


        function updateModelinfo(testId,handle)

            if isempty(testId)
                testId=cv('get',get_param(handle,'CoverageId'),'.activeTest');
            end
            if testId==0
                return;
            end
            ownerModel=cv('get',testId,'.ownerModel');
            if~isempty(ownerModel)
                handle=get_param(ownerModel,'Handle');
            end
            strParNames={'modelVersion','creator','lastModifiedDate'};
            for pn=strParNames(:)'
                cv('set',testId,['.',pn{1}],get_param(handle,pn{1}));
            end
            cvi.TopModelCov.updateSimulationOptimizationOptions(testId,handle);
        end



        function updateSimulationOptimizationOptions(testId,handle)
            cv('set',testId,'.defaultParameterBehavior',get_param(handle,'DefaultParameterBehavior'));
            cv('set',testId,'.conditionallyExecuteInputs',strcmpi(get_param(handle,'conditionallyExecuteInputs'),'on'));
            status=get_param(handle,'BlockReduction');
            forceBlockReductionOff=cv('get',testId,'.forceBlockReductionOff');
            if strcmpi(status,'on')&&~isempty(forceBlockReductionOff)&&forceBlockReductionOff
                status='forcedOff';
            end
            cv('set',testId,'.blockReductionStatus',status);
        end

        function res=getFilterAppliedStruct()
            res=cvi.CovFilterUtils.getFilterAppliedStruct();
        end

        function sds=getScriptDataStruct()
            sds=struct('scriptPath','',...
            'scriptName','',...
            'cvScriptId',0,...
            'isAllocated',false,...
            'oldRootId',0,...
            'chartIdStrs',[]);
        end

        scriptName=getScriptNameFromPath(scriptPath)
    end
end


