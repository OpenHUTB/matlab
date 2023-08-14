classdef Coverage<handle




    properties(Constant)
        CovSaveName='sltest_covdata';
        CoverageParams={'RecordCoverage','CovFilter','CovMetricSettings',...
        'CovHtmlReporting','CovEnableCumulative','CovSaveName',...
        'CovSaveSingleToWorkspaceVar','CovExternalEMLEnable',...
        'CovSFcnEnable','CovModelRefEnable','CovPath'...
        ,'CovSaveOutputData','CovOutputDir','CovShowResultsExplorer',...
        'CovEnable'};
    end

    properties(Access=private)
        modelName;
        harnessName;
        ownerType;
        ownerFullPath;
        coverageSettings;
    end

    properties(Constant)
        NONEXISTENT=0;
        MODEL=4;
        EXPORT_BASE_WORKSPACE=0;
        EXPORT_FILE=1;
    end

    methods

        function this=Coverage(coverageSettings,simWatcher,runtestcfg)
            import stm.internal.Coverage;
            this.modelName=simWatcher.mainModel;
            this.harnessName=simWatcher.harnessName;
            this.coverageSettings=coverageSettings;
            this.initHarnessCoverageSettings;

            if runtestcfg.runUsingSimIn
                return;
            end

            modelToRun=this.getModelToRun;
            if coverageSettings.RecordCoverage
                recordCoverage='on';
            else
                recordCoverage='off';
            end


            param='RecordCoverage';
            simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
            set_param(modelToRun,param,recordCoverage);


            param='CovHtmlReporting';
            simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
            set_param(modelToRun,param,'off');


            param='CovShowResultsExplorer';
            simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
            set_param(modelToRun,param,'off');

            if coverageSettings.CollectingCoverage

                param='CovMetricSettings';
                oldSettings=get_param(modelToRun,param);
                simWatcher.cleanupTestCase.(param)=oldSettings;
                new=Coverage.getCovMetricSettings(oldSettings,coverageSettings.MetricSettings);

                set_param(modelToRun,param,[new,'e']);



                if~strcmp(coverageSettings.CoverageFilterFilename,...
                    stm.internal.MRT.share.getString('stm:SystemUnderTestView:ModelSettings'))
                    param='CovFilter';
                    covFilter=coverageSettings.CoverageFilterFilename;
                    simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
                    set_param(modelToRun,param,covFilter);
                end


                param='CovEnableCumulative';
                simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
                set_param(modelToRun,param,'off');


                param='CovSaveSingleToWorkspaceVar';
                simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
                set_param(modelToRun,param,'on');


                param='CovSaveName';
                simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
                set_param(modelToRun,param,Coverage.CovSaveName);


                param='CovExternalEMLEnable';
                simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
                set_param(modelToRun,param,'on');


                param='CovSFcnEnable';
                simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
                set_param(modelToRun,param,'on');

                setModelReferenceCoverage(simWatcher,modelToRun,...
                this.getMdlRefValue);



                subsystem='/';
                param='CovPath';
                simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
                set_param(modelToRun,param,subsystem);


                param='CovSaveOutputData';
                simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
                set_param(modelToRun,param,'off');


                param='CovOutputDir';
                simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
                set_param(modelToRun,param,'');
            else

                param='CovEnable';
                simWatcher.cleanupTestCase.(param)=get_param(modelToRun,param);
                set_param(modelToRun,param,'off');
            end
        end


        coverageResults=save(this,runInfo);
        modelToRun=getModelToRun(this);
        mdlRefValue=getMdlRefValue(this);
        simIn=getSimInput(this,simInput,fastRestart);
    end

    methods(Static)
        coverageResults=saveHelper(modelName,harnessName,runInfo,simOut);
        [onwerType,ownerFullPath]=initHarnessCovSettingsHelper(model,harness);
        runInfo=populateRunInfo(simInput);

        coverageResults=getMetrics(covObjects,ownerType,ownerFullPath,varargin);
        coverageResults=getCoverageResultsStruct();

        analyzedModel=getAnalyzedModel(cvdataObj,ownerType,ownerFullPath);

        [slvnvAnalyzedModel,isHarnessOpen]=getSlvnvAnalyzedModel(...
        cvdataObj,analyzedModel,ownerType,ownerFullPath);


        filename=saveToFile(cvdataObj);


        coverageResults=add(cr,rs,resultID);

        filename=addAndReturnFile(filenames,coverageResultIds,groupStartIndices,...
        isTopLevelModel,resultSetID,resultID);

        reportFiles=report(filenames,topLevelModel,launchReport,resultSetID);
        modelView(filenames,analyzedModel,~,resultSetID);
        model=openLibrary(cvdata,model,harnessOwner);

        data=loadCovObjects(filename,analyzedModel);
        [errMsg,errId]=getCovErrorMsg(analyzedModel,baseErrId);

        ownerModels=getOwnerModel(modelinfo);


        filename=tempname();


        covHTMLSettings=getHTMLSettings(model);

        out=getCoverageResults(out,simWatcher,simInputs,varargin);

        status=getStatus(name);

        bool=isModel(name);

        bool=isLibrary(model);

        ret=flattenCovObjects(covObjects);

        [cvResults,isValidCvResults]=filenamesToCvDataArray(filenames,topmodels);

        [nameIsAvailable,invalidNameError]=export(filenames,...
        exportName,exportType,forceOverwrite);

        coverageSettings=getCoverageSettings(callingFunction,testId);

        oc=restoreLibraryLock(library);
        bool=isNotUnique(model);
        [bRecordCoverage,bMdlRefCoverage,bUseCoverageFilter,bCoverageFilterName,metricSettings]=...
        getModelCoverageSettings(model);
        applyFilter(rs,newFilterFiles);
        hasReqs=scopeDataToReqs(rs,shouldScope);
        filterEditStartCallback(resultId);
        filterEditEndCallback(resultId,filterFileNames);
        files=normalizeExtensions(files);
        tfNames=updateTestFileFilters(rsID);
        filterFiles=getFilterFiles(isResultSet,rs);
        resultStruct=getMergedCoverage(models,testCaseResults);
        release=fetchReleaseFromCvtFile(fileName);
    end

    methods(Static,Access=private)
        new=getCovMetricSettings(old,new);
        safeSlvnv(fcnHandle,analyzedModel,type,args);
        rs=getResultSetObj(rs);
        getNewCovMetricsAndUpdateDB(crID,covObjects);
    end

    methods(Access=private)
        initHarnessCoverageSettings(this);
    end
end

function setModelReferenceCoverage(simWatcher,modelToRun,mdlRefValue)
    param='CovModelRefEnable';
    currentValue=get_param(modelToRun,param);
    if strcmp(mdlRefValue,'on')&&strcmp(currentValue,'filtered')

    else
        simWatcher.cleanupTestCase.(param)=currentValue;
        set_param(modelToRun,param,mdlRefValue);
    end
end
