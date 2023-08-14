




classdef RunTestCase<Sldv.SimModel





    properties(Access=protected)

        ModelH=[];


        Model='';


        SldvData=[];



        SimDataTimeSeries=[];


        FunTs=[];


        InportBlkHs=[];


        OutportBlkHs=[];


        OutputFormat='SimulationOutput';


        SignalLoggingSaveFormat='Dataset';



        BaseWSParamsCached=[];



        BaseWSSldvDataName='';


        IsXilMode=false;
        XilModeInfo=[];





        isBDExtractedModel=false;
    end

    properties(Access=private)


        OrigModelH=[];



        OrigModel='';


        GetCoverage=false;


        CvTestSpec=[];



        InterpolationChangedInportIdx=[];



        OutData=[];


        CvData=[];


        fastRestartMode=false;


        paramNameValStruct=[];


        simInput=Simulink.SimulationInput.empty;


        simManagerEngine=Simulink.SimulationManagerEngine.empty;


        simManager=Simulink.SimulationManager.empty;


        modelRefInputsMap=[];



        origWarningStates=[];
        sfDebuggerState=[];
        taskingArchff=[];


        sigInfo=Simulink.SimulationData.SignalLoggingInfo.empty;


        useParallel=false;


        baseWorkSpaceVarsCached=false;


        modelHasUnconnectedOutports=false;



        expectedOutput=false;



        isEmptyInstrumentedSignals=[];
    end

    methods
        function obj=RunTestCase(utilityName,isvnvmode,utilityNameCheck)
            if nargin<3
                utilityNameCheck=true;
            end
            if nargin<2
                isvnvmode=false;
            end
            if nargin<1
                utilityName='sldvruntest';
            end
            if utilityNameCheck&&...
                ~any(strcmp(utilityName,{'sldvruntest','slvnvruntest','Validator'}))
                error(message('Sldv:RunTestCase:UnableToCreateConstructor'));
            end
            if utilityNameCheck
                isvnvmode=strcmp(utilityName,'slvnvruntest');
            end
            if isvnvmode
                invalid=~SlCov.CoverageAPI.checkCvLicense();
                if invalid
                    error(message('Sldv:RunTestCase:SimulinkCoverageNotLicensed'));
                end
            else
                invalid=builtin('_license_checkout','Simulink_Design_Verifier','quiet');
                if invalid
                    error(message('Sldv:RunTestCase:SimulinkDesignVerifierNotLicensed'));
                end
            end
            obj=obj@Sldv.SimModel;
            if isvnvmode
                obj.MsgIdPref='Slvnv:RUNTEST:';
            else
                obj.MsgIdPref='Sldv:RUNTEST:';
            end
            obj.SignalLoggerPrefix=Sldv.RunTestCase.getLoggingPrefix;
            obj.UtilityName=utilityName;
            obj.ModelLogger=sprintf('logsout_%s',utilityName);
        end

        varargout=simTestCases(obj,model,sldvData,varargin);


        initialize(obj,model,sldvData,varargin);

        simData=runSimulation(obj,testcase,propertyProvingBlocks);

        [simOut,covOut]=getSimulationResults(obj,simData);

        handleException(obj,Mex);
    end

    methods(Hidden)
        function restore(obj)
            obj.resetSessionData();
        end

        function turnOffFastRestart(obj)
            if obj.fastRestartMode
                if obj.useParallel
                    wait(parfevalOnAll(obj.simManager.SimulationRunner.Pool,@set_param,0,obj.Model,'FastRestart','off'));
                else
                    set_param(obj.ModelH,'FastRestart','off');
                end
            end
        end

        function turnOnFastRestart(obj)
            if obj.fastRestartMode
                if obj.useParallel
                    wait(parfevalOnAll(obj.simManager.SimulationRunner.Pool,@set_param,0,obj.Model,'FastRestart','on'));
                else
                    set_param(obj.ModelH,'FastRestart','on');
                end
            end
        end
    end

    methods(Access=protected)
        configureLoggers(obj);

        function deriveModelParam(obj,model)
            [modelH,errStr]=Sldv.utils.getObjH(model);

            if~isempty(errStr)||...
                ~strcmp(get_param(modelH,'Type'),'block_diagram')||...
                strcmp(get_param(modelH,'Type'),'block_diagram')&&strcmp(get_param(modelH,'BlockDiagramType'),'library')
                obj.handleMsg('error',message('Sldv:RunTestCase:InvalidFirstInput',obj.UtilityName,errStr));
            end
            obj.ModelH=modelH;
            obj.Model=get_param(modelH,'Name');
        end

        function createXilHarnessForSimulation(obj,testGenModelRefMode)


            modelH=obj.OrigModelH;
            modelName=obj.OrigModel;
            dirtyFlag=get_param(modelName,'Dirty');
            fastRestartStatus=get_param(modelName,'FastRestart');
            if~obj.isBDExtractedModel
                harnessModelName='HARNESS_4_SLDV_SIL_CODEGEN_VALIDATION';
                harnesslist=Simulink.harness.internal.find(modelName);
                if~isempty(harnesslist)
                    for idx=1:numel(harnesslist)
                        if harnesslist(idx).isOpen
                            Simulink.harness.internal.close(modelName,harnesslist(idx).name);
                        end
                    end
                end
                harnesslist=Simulink.harness.internal.find(modelName,'Name',harnessModelName);
                if~isempty(harnesslist)
                    Simulink.harness.internal.delete(modelH,harnessModelName);
                end

                set_param(modelName,'Dirty','off','FastRestart','off');
                Simulink.harness.internal.create(modelName,...
                false,...
                false,...
                'Name',harnessModelName,'Source','Inport',...
                'DriveFcnCallWithTestSequence',false,...
                'SLDVCompatible',true,'VerificationMode','SIL');
                Simulink.harness.internal.load(modelName,harnessModelName,false);
                if testGenModelRefMode
                    blockUT=Simulink.harness.internal.getActiveHarnessCUT(modelName);
                    set_param(blockUT,'CodeInterface','Model reference');
                end
                obj.Model=harnessModelName;
                obj.ModelH=get_param(harnessModelName,'Handle');
                set_param(modelName,'Dirty',dirtyFlag,'FastRestart',fastRestartStatus);
            end
        end

        function deletedXilHarnessForSimulation(obj)


            modelH=obj.OrigModelH;
            harnessModelName=obj.Model;
            modelName=get_param(modelH,'Name');
            harnesslist=Simulink.harness.internal.find(modelName,'Name',harnessModelName);
            if~isempty(harnesslist)
                oldValue=get_param(obj.OrigModel,'Dirty');
                if harnesslist.isOpen



                    set_param(harnessModelName,'Dirty','off');
                    Simulink.harness.internal.close(modelH,harnessModelName);
                end
                Simulink.harness.internal.delete(modelH,harnessModelName);
                set_param(obj.OrigModel,'Dirty',oldValue);
            end
        end


        function covData=fixTopModelCovIdForXIL(obj,covData)

            sldvOptions=obj.SldvData.AnalysisInformation.Options;
            if Sldv.utils.Options.isTestgenTargetForModelRefCode(sldvOptions)
                covMode='ModelRefSIL';
            elseif Sldv.utils.Options.isTestgenTargetForCode(sldvOptions)
                covMode='SIL';
            else
                return
            end

            cvdName=obj.OrigModel;
            for ii=1:numel(covData)

                if isa(covData{ii},'cvdata')
                    cvdg=cv.cvdatagroup(covData{ii});
                elseif isa(covData{ii},'cv.cvdatagroup')
                    cvdg=covData{ii};
                else

                    continue
                end


                cvd=cvdg.get(cvdName,covMode);
                if isempty(cvd)
                    continue
                end




                topModelCovId=cv('get',cvd.rootID,'.modelcov');
                oldTopModelCovId=cv('get',topModelCovId,'.topModelcovId');
                cv('set',oldTopModelCovId,'.refModelcovIds',[]);


                allCvds=cvdg.getAll();
                allModelIds=zeros(1,numel(allCvds));
                for jj=1:numel(allCvds)
                    allModelIds(jj)=cv('get',allCvds{jj}.rootID,'.modelcov');
                    cv('set',allModelIds(jj),'.topModelcovId',topModelCovId);
                end
                cv('set',topModelCovId,'.refModelcovIds',allModelIds);
            end
        end


        function deriveSldvDataParam(obj,sldvData)
            if ischar(sldvData)||isstring(sldvData)
                rawdata=obj.loadSldvDataFromFile(sldvData);
                dataFields=fields(rawdata);
                if length(dataFields)==1
                    sldvData=rawdata.(dataFields{1});
                else
                    obj.handleMsg('error',message('Sldv:RunTestCase:InvalidDataFormat',obj.UtilityName));
                end
            end

            sldvData=...
            Sldv.DataUtils.convertToCurrentFormat(obj.ModelH,sldvData);



            if~isempty(sldvData)&&...
                (strcmp(get_param(obj.ModelH,'IsExportFunctionModel'),'on')||...
                (strcmp(get_param(obj.ModelH,'type'),'block_diagram')&&...
                sldvshareprivate('mdl_has_missing_slfunction_defs',obj.ModelH)))
                extractedMdl=sldvprivate('getExtractedMdl',sldvData,obj.ModelH);
                deriveModelParam(obj,extractedMdl);
            end

            obj.isBDExtractedModel=Sldv.DataUtils.isBDExtractedModel(sldvData);

            [sldvData,errStr]=Sldv.DataUtils.convertLoggedSldvDataToHarnessDataFormat(sldvData);
            if~isempty(errStr)
                obj.handleMsg('error',message('Sldv:RunTestCase:InvalidDataFormat1',obj.UtilityName,errStr));
            end

            sldvData=Sldv.DataUtils.derivedDataToCommonFormat(sldvData);

            obj.SldvData=sldvData;

            simData=Sldv.DataUtils.getSimData(obj.SldvData);
            if isempty(simData)&&~strcmp(obj.UtilityName,'Validator')
                obj.handleMsg('error',message('Sldv:RunTestCase:NoTestCase'));
            end
        end

        [simOut,covOut]=runTests(obj);

        convertSldvDataToTimeSeries(obj,simData);



        deriveNonCGVParams(obj,runtestOpts);



        setupParallelPool(obj);



        function fullRuntestOpts=checkRuntestOpts(obj,runtestOpts,type)
            if nargin<3
                type='';
            end
            errMsg=Sldv.RunTestCase.iscorrectRuntestOpts(runtestOpts,type);
            if~isempty(errMsg)
                obj.handleMsg('error','Sldv:RunTestCase:RuntestOptsVal',errMsg);
            else
                fullRuntestOpts=Sldv.RunTestCase.getRuntestOpts(type);
                if strcmp(type,'cgv')&&~isfield(runtestOpts,'signalLoggingSaveFormat')
                    runtestOpts.signalLoggingSaveFormat='ModelDataLogs';
                end
                currentfields=fieldnames(runtestOpts);
                for idx=1:length(currentfields)
                    fullRuntestOpts.(currentfields{idx})=runtestOpts.(currentfields{idx});
                end
                if isfield(fullRuntestOpts,'outputFormat')&&...
                    ~strcmp(fullRuntestOpts.outputFormat,'SimulationOutput')
                    obj.handleMsg('warning',message('Sldv:RunTestCase:OutputFormatDeprecated',obj.UtilityName));
                else
                    fullRuntestOpts.outputFormat='SimulationOutput';
                end
                if isfield(runtestOpts,'fastRestart')&&runtestOpts.fastRestart
                    obj.fastRestartMode=true;
                end

                if isfield(runtestOpts,'expectedOutput')&&runtestOpts.expectedOutput
                    obj.expectedOutput=true;
                end

                if isfield(runtestOpts,'useParallel')&&runtestOpts.useParallel
                    obj.useParallel=true;


                    if((strcmp(obj.UtilityName,'sldvruntest')||...
                        strcmp(obj.UtilityName,'slvnvruntest'))&&...
                        ~slavteng('feature','UseParSimForRunTest'))

                        obj.useParallel=false;
                    end
                end
            end
        end

        checkSldvData(obj,modelToCheck)



        function resetSessionData(obj)


            if obj.fastRestartMode
                set_param(obj.ModelH,'FastRestart','off');
            end
            obj.restoreLoggers;
            obj.restoreModelRefSettings;
            if obj.useParallel

                obj.clearSimManager;
            end


            Sldv.utils.getBusObjectFromName(-1);
            Sldv.DataUtils.convertTestCasesToSLDataSet(-1);


            Sldv.utils.manageAliasTypeCache('clear');












            obj.restoreIfEmptyInstrumentedSignals();

            resetSessionData@Sldv.SimModel(obj);


            if obj.IsXilMode&&~obj.isXilAtomicSubsystem()&&...
                ~obj.isBDExtractedModel
                obj.deletedXilHarnessForSimulation();
            else
                obj.destroyTmpModel;
            end






            if obj.IsXilMode&&~obj.isXilAtomicSubsystem()&&...
                ~obj.isBDExtractedModel
                sldvprivate('settings_handler',obj.OrigModelH,'restore_global_ws');
            else
                sldvprivate('settings_handler',obj.ModelH,'restore_global_ws');
            end
        end

        function findMdlReferences(obj)
            obj.ModelHsNormalMode=obj.ModelH;
            obj.ModelHsInMdlRefTree=obj.ModelH;
            obj.DirtyStatus.(obj.Model)=get_param(obj.ModelH,'Dirty');
            obj.findBlocksInMdlRefTree(obj.ModelH);
        end

        function storeOriginalModelParams(obj)
            settingsCache=[];
            settingsCache.OldConfigSet=getActiveConfigSet(obj.ModelH);



            if~obj.isXilAtomicSubsystem()
                settingsCache.SimulationMode=get_param(obj.ModelH,'SimulationMode');
            end

            settingsCache.FastRestartMode=get_param(obj.ModelH,'FastRestart');
            if obj.GetCoverage
                settingsCache=Sldv.SimModel.updateEMLSFSettings(obj.ModelH,settingsCache);
            end

            obj.SettingsCache=settingsCache;
        end

        function restoreOriginalModelParams(obj)
            if~isempty(obj.SettingsCache)
                Sldv.utils.restoreConfigSet(obj.ModelH,obj.SettingsCache.OldConfigSet);
                if isfield(obj.SettingsCache,'SfDebugSettings')
                    Sldv.utils.setSFDebugSettings(obj.ModelH,obj.SettingsCache.SfDebugSettings);
                end

                if~obj.isXilAtomicSubsystem()
                    set_param(obj.ModelH,'SimulationMode',obj.SettingsCache.SimulationMode);
                end

                set_param(obj.ModelH,'FastRestart',obj.SettingsCache.FastRestartMode);
                obj.restoreDirtyStatus;
                obj.SettingsCache=[];
            end
        end

        derivePortHandlesToLog(obj)

        changeModelParameters(obj)

        function simInput=changeInterpForInports(obj,simInput)





            if nargin<2
                simInput=[];
            end



            inputPortInfo=obj.SldvData.AnalysisInformation.InputPortInfo;
            numIports=length(inputPortInfo);

            inportIdxChanged=zeros(1,numIports);

            for idx=1:numIports
                if~sldvshareprivate('isBusElem',obj.InportBlkHs(idx))&&...
                    strcmp(get_param(obj.InportBlkHs(idx),'Interpolate'),'on')&&...
                    Sldv.RunTestCase.nointerpDataType(inputPortInfo{idx},obj.ModelH)
                    if nargin==1
                        set_param(obj.InportBlkHs(idx),'Interpolate','off');
                    else
                        simInput=setBlockParameter(simInput,getfullname(obj.InportBlkHs(idx)),'Interpolate','off');
                    end
                    inportIdxChanged(idx)=1;
                end
            end

            obj.InterpolationChangedInportIdx=inportIdxChanged;
        end

        function clearSimManager(obj)




            pool=gcp('nocreate');
            if~isempty(pool)&&~isempty(obj.simManagerEngine)

                if~isempty(obj.origWarningStates)
                    obj.executeInParallel(pool,@warning,0,obj.origWarningStates);
                    obj.origWarningStates=[];
                end

                sfState=obj.sfDebuggerState;
                obj.executeInParallel(pool,@eval,0,...
                ['sf(''Private'', ''testing_stateflow_in_bat'', ',int2str(sfState),')']);

                taskingArchValue=obj.taskingArchff;
                obj.executeInParallel(pool,@eval,0,...
                ['slfeature(''SldvTaskingArchitecture'', ',int2str(taskingArchValue),')']);
                obj.simManagerEngine.cleanup();
                obj.simManagerEngine=Simulink.SimulationManagerEngine.empty;
                obj.simManager=Simulink.SimulationManager.empty;
            end
        end

        function configureSimManager(obj)





            pool=gcp('nocreate');
            set_param(obj.Model,'Dirty','off');
            obj.simManager=Simulink.SimulationManager(obj.Model);
            obj.simManager.Options.RunInBackground='on';






            obj.simManager.AutoCleanup=false;
            obj.simManagerEngine=obj.simManager.SimulationManagerEngine;
            obj.simManagerEngine.Options.TransferBaseWorkspaceVariables='on';
            obj.simManagerEngine.Options.UseParallel=true;




            obj.taskingArchff=fetchOutputs(parfeval(pool,@eval,1,...
            "slfeature('SldvTaskingArchitecture')"));
            obj.executeInParallel(pool,@eval,0,...
            "slfeature('SldvTaskingArchitecture',0)");


            obj.origWarningStates=fetchOutputs(parfeval(pool,@warning,1));
            clientWarningState=warning;
            obj.executeInParallel(pool,@warning,0,clientWarningState);




            warnBTModeName='backtrace';
            warnBTModeState=fetchOutputs(parfeval(pool,@warning,1,'query',warnBTModeName));
            obj.origWarningStates(end+1)=warnBTModeState;
            obj.executeInParallel(pool,@warning,0,'off',warnBTModeName);


            obj.sfDebuggerState=fetchOutputs(parfeval(pool,@eval,1,...
            "sf('Private', 'testing_stateflow_in_bat')"));
            obj.executeInParallel(pool,@eval,0,...
            "sf('Private', 'testing_stateflow_in_bat', 1)");

            obj.simManagerEngine.setup();
        end

        function handleModelRefSettings(obj)





            entries=obj.modelRefInputsMap.keys;
            if~isempty(entries)
                for idx=1:length(entries)
                    modelName=entries{idx};
                    modelH=get_param(modelName,'Handle');
                    origDirty=get_param(modelH,'Dirty');
                    modelSimInput=obj.modelRefInputsMap(entries{idx});
                    modelSimInput.applyToModel('EnableConfigSetRefUpdate','on');
                    set_param(modelH,'Dirty',origDirty);
                end
            end
        end

        function applyModelSettings(obj)

            hasAutoSave=find(contains({obj.simInput.Variables.Name},'AutoSaveOptions'),1);


            obj.configureLoggers;

            if~isempty(hasAutoSave)


                set_param(0,obj.simInput.Variables(hasAutoSave).Name,obj.simInput.Variables(hasAutoSave).Value);



                obj.simInput.Variables(hasAutoSave)=[];
            end


            obj.handleModelRefSettings;





            obj.simInput.applyToModel('EnableConfigSetRefUpdate','on');

            if obj.useParallel




                if obj.fastRestartMode


                    set_param(obj.Model,'FastRestart','on');
                else
                    set_param(obj.Model,'FastRestart','off');
                end

                set_param(obj.Model,'Dirty','off');
            else


                if obj.fastRestartMode
                    set_param(obj.ModelH,'FastRestart','on');
                else
                    set_param(obj.ModelH,'FastRestart','off');
                end
            end
        end

        function restoreModelRefSettings(obj)
            obj.modelRefInputsMap=[];
        end

        function initForSim(obj)
            Sldv.utils.replaceConfigSetRefWithCopy(obj.ModelH);


            obj.changeModelParameters;


            obj.sigInfo=obj.getSigInfo;

            obj.simInput=obj.changeInterpForInports(obj.simInput);

            simInputStruct=obj.getBaseSimStruct;
            obj.simInput=obj.assignModelParametersToSimulationInput(obj.simInput,simInputStruct);


            if obj.useParallel




                LoggerId='sldv::dv';
                logStr=sprintf('RunTestCase - Starting parallel pool setup');
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
                try
                    obj.configureSimManager;



                    if~isa(obj.simManager.SimulationRunner,...
                        'MultiSim.internal.SimulationRunnerParallelLocal')

                        errorMsg='MultiSim.internal.SimulationRunnerParallelLocal object could not be created';
                        obj.useParallel=false;
                    end
                catch Mex

                    errorMsg=Mex.message;
                    obj.useParallel=false;
                end


                if obj.useParallel
                    logStr=sprintf('RunTestCase - Completed parallel pool setup');
                else



                    obj.handleMsg('warning',message('Sldv:RunTestCase:ParPoolSetupFailed'));
                    logStr=sprintf('RunTestCase - Parallel pool setup failed with the error: "%s"',errorMsg);
                end
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
            end



            if obj.useParallel



                refModels=obj.modelRefInputsMap.keys;
                for modelIdx=1:length(refModels)
                    isLoadedFuture=parfevalOnAll(obj.simManager.SimulationRunner.Pool,@bdIsLoaded,1,refModels{modelIdx});
                    isLoaded=all(fetchOutputs(isLoadedFuture)==1);
                    if~isLoaded
                        parOp=parfevalOnAll(obj.simManager.SimulationRunner.Pool,@load_system,0,refModels{modelIdx});
                        wait(parOp);
                        assert(isempty(parOp.Error),['Loading model:',refModels{modelIdx},' on the parallel workers failed']);
                    end
                end





                allModels=[obj.Model,string(refModels)];
                obj.executeInParallel(obj.simManager.SimulationRunner.Pool,@disableSFDebugInParallel,0,obj,allModels);



                obj.executeInParallel(@applyModelSettings,0,obj);
            else
                obj.applyModelSettings;
            end

            if obj.OrigModelH==obj.ModelH


                set_param(obj.ModelH,'Dirty','off');
            else


                set_param(obj.OrigModelH,'Dirty','off');
                set_param(obj.ModelH,'Dirty','off');
            end
        end

        function warningIds=listWarningsToTurnForLogging(obj)
            warningIds={};
            if~isempty(obj.PortHsToLog)
                warningIds{end+1}={'Simulink:Engine:OutportCannotLogNonBuiltInDataTypes'};
            end
            if obj.IsXilMode

                warningIds{end+1}={'PIL:pil:UnsupportedLoggedStates'};
            end















        end


        function restoreInterpForInports(obj)
            if~isempty(obj.InterpolationChangedInportIdx)
                portsChanged=obj.InportBlkHs(logical(obj.InterpolationChangedInportIdx));
                for idx=1:length(portsChanged)
                    set_param(portsChanged(idx),'Interpolate','on');
                end
                obj.InterpolationChangedInportIdx=[];
            end
        end

        function paramNameValStruct=getBaseSimStruct(obj)
            paramNameValStruct=[];

            paramNameValStruct.StartTime='0.0';


            if strcmp(obj.UtilityName,'Validator')









                paramNameValStruct.BlockReduction='on';
            end



            if strcmp(obj.UtilityName,'Validator')&&...
                strcmp(obj.SldvData.AnalysisInformation.Options.Mode,'PropertyProving')






                paramNameValStruct.AssertControl='UseLocalSettings';
            elseif strcmp(obj.UtilityName,'Validator')&&...
                slavteng('feature','DedValidation')&&...
                strcmp(obj.SldvData.AnalysisInformation.Options.Mode,'DesignErrorDetection')



                if strcmp(obj.SldvData.AnalysisInformation.Options.DetectOutOfBounds,'on')
                    paramNameValStruct.ArrayBoundsChecking='warning';
                end



                if strcmp(obj.SldvData.AnalysisInformation.Options.DetectIntegerOverflow,'on')
                    paramNameValStruct.IntegerOverflowMsg='warning';
                    paramNameValStruct.ParameterDowncastMsg='warning';
                    paramNameValStruct.ParameterOverflowMsg='warning';
                    paramNameValStruct.FixptConstOverflowMsg='warning';
                end

                if strcmp(obj.SldvData.AnalysisInformation.Options.DetectInfNaN,'on')||...
                    strcmp(obj.SldvData.AnalysisInformation.Options.DetectSubnormal,'on')
                    paramNameValStruct.SignalInfNanChecking='warning';
                end

                if strcmp(obj.SldvData.AnalysisInformation.Options.DetectBlockInputRangeViolations,'on')||...
                    strcmp(obj.SldvData.AnalysisInformation.Options.DesignMinMaxCheck,'on')
                    paramNameValStruct.SignalRangeChecking='warning';
                end
            end






            paramNameValStruct.ModelReferenceCSMismatchMessage='none';
            paramNameValStruct.UpdateModelReferenceTargets='IfOutOfDate';




            if~obj.isXilAtomicSubsystem()
                paramNameValStruct.SimulationMode='normal';
            end

            if~obj.GetCoverage
                paramNameValStruct.SFSimEnableDebug='off';
                paramNameValStruct.RecordCoverage='off';
                paramNameValStruct.CovModelRefEnable='off';
                paramNameValStruct.CovExternalEMLEnable='off';
                paramNameValStruct.CovSFcnEnable='off';
            else
                if strcmp(obj.UtilityName,'Validator')
                    paramNameValStruct.CovScope='EntireSystem';
                else
                    paramNameValStruct.CovPath='/';
                end
                paramNameValStruct.RecordCoverage='on';
                paramNameValStruct.CovEnable='on';
                paramNameValStruct.CovExternalEMLEnable='on';
                paramNameValStruct.CovSFcnEnable='on';

                if isempty(obj.CvTestSpec)


                    paramNameValStruct.CovModelRefEnable='on';
                    if(obj.IsXilMode&&obj.isBDExtractedModel)||obj.isXilAtomicSubsystem()
                        paramNameValStruct.CovIncludeTopModel='off';
                    else
                        paramNameValStruct.CovIncludeTopModel='on';
                    end
                    paramNameValStruct.CovModelRefExcluded='';
                end

                paramNameValStruct.CovSaveSingleToWorkspaceVar='on';
                paramNameValStruct.CovSaveName='coveragedata';
                paramNameValStruct.CovNameIncrementing='off';
                paramNameValStruct.CovShowResultsExplorer='off';
                paramNameValStruct.CovHighlightResults='off';
                paramNameValStruct.CovHtmlReporting='off';
                paramNameValStruct.CovEnableCumulative='off';













                paramNameValStruct.CovSaveOutputData='on';




                paramNameValStruct.CovOutputDir=[obj.SldvData.AnalysisInformation.Options.OutputDir...
                ,filesep,'sldv_covoutput'];
            end

            if sldvshareprivate('mdl_issampletimeindep',obj.ModelH)&&~obj.IsXilMode
                paramNameValStruct.SampleTimeConstraint='Unconstrained';
            end
            if~strcmp(get_param(obj.ModelH,'SampleTimeConstraint'),'Specified')
                paramNameValStruct.FixedStep=sldvshareprivate('util_double2str',obj.FunTs);
            end

            paramNameValStruct.InheritedTsInSrcMsg='none';
            modelHasRootLevelBEP=sldvshareprivate('mdl_check_rootlvl_buselemport',obj.ModelH);



            if~(obj.expectedOutput||strcmp(obj.UtilityName,'Validator'))&&~modelHasRootLevelBEP





























                [~,modelBlocks]=find_mdlrefs(obj.ModelH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
                if~isempty(modelBlocks)

                    countMdlRefDataset=0;

                    numMdlRefs=length(modelBlocks);
                    for i=1:numMdlRefs
                        refModel=get_param(modelBlocks(i),'ModelName');
                        if strcmp(get_param(refModel,'SaveFormat'),'Dataset')
                            countMdlRefDataset=countMdlRefDataset+1;
                        end
                    end
                    if countMdlRefDataset==numMdlRefs


                        paramNameValStruct.SaveFormat='Dataset';
                    elseif countMdlRefDataset>0


                        paramNameValStruct.SaveFormat=get_param(obj.ModelH,'SaveFormat');
                    else

                        paramNameValStruct.SaveFormat='StructureWithTime';
                    end
                else

                    paramNameValStruct.SaveFormat='StructureWithTime';
                end
            else



                paramNameValStruct.SaveFormat='Dataset';
            end














            if~(obj.expectedOutput||strcmp(obj.UtilityName,'Validator'))
                paramNameValStruct.SaveState='on';
                paramNameValStruct.StateSaveName=sprintf('xout_%s',obj.UtilityName);
                paramNameValStruct.SaveOutput='on';
                paramNameValStruct.OutputSaveName=obj.getOutputSaveName(paramNameValStruct.SaveFormat);
                paramNameValStruct.SaveTime='on';
                paramNameValStruct.TimeSaveName=sprintf('tout_%s',obj.UtilityName);
            else



                paramNameValStruct.SaveState='off';
                paramNameValStruct.SaveFinalState='off';
                paramNameValStruct.SaveTime='off';
                paramNameValStruct.DSMLogging='off';
                if obj.modelHasUnconnectedOutports



                    paramNameValStruct.SaveOutput='on';
                    paramNameValStruct.OutputSaveName=obj.getOutputSaveName(paramNameValStruct.SaveFormat);
                else

                    paramNameValStruct.SaveOutput='off';
                end



                paramNameValStruct.DatasetSignalFormat='timeseries';
            end
            paramNameValStruct.LimitDataPoints='off';
            paramNameValStruct.Decimation='1';
            paramNameValStruct.SignalLoggingName=obj.ModelLogger;

            if strcmp(obj.SignalLoggingSaveFormat,'ModelDataLogs')
                paramNameValStruct.SignalLogging='on';
                paramNameValStruct.SignalLoggingSaveFormat='ModelDataLogs';
            elseif strcmp(obj.SignalLoggingSaveFormat,'Dataset')
                paramNameValStruct.StrictBusMsg='ErrorLevel1';
                paramNameValStruct.SignalLogging='on';
                paramNameValStruct.SignalLoggingSaveFormat='Dataset';
            else
                paramNameValStruct.SignalLogging='off';
            end
            paramNameValStruct.LoggingToFile='off';



            cvtestParamNameValStruct=obj.convertCvTestToModelParameters;

            fieldNames=fields(cvtestParamNameValStruct);
            for fieldIdx=1:length(fieldNames)
                paramNameValStruct.(fieldNames{fieldIdx})=cvtestParamNameValStruct.(fieldNames{fieldIdx});
            end
        end

        function paramNameValStruct=modifySimstruct(~,~,paramNameValStruct,~)




        end

        function str=genExternalInputStrForTestCase(obj,tcIdx,incrementalMode)
            if nargin<3
                incrementalMode=false;
            end
            if isfield(obj.SldvData,'TestCases')
                simDataFieldName='TestCases';
            else
                simDataFieldName='CounterExamples';
            end
            if~incrementalMode
                str=sprintf('%s.%s(%d).dataValues',obj.BaseWSSldvDataName,simDataFieldName,tcIdx);
            else
                str=sprintf('%s.dataValues',obj.BaseWSSldvDataName);
            end
        end

        function status=isXilAtomicSubsystem(obj)
            status=sldv.code.internal.isAtsEnabled()&&...
            obj.IsXilMode&&...
            ~isempty(obj.XilModeInfo)&&...
            isfield(obj.XilModeInfo,'isATS')&&...
            (obj.XilModeInfo.isATS==true);
        end

        function markPresenceOfInstrumentedSignals(obj)
            if isempty(get_param(obj.ModelH,'InstrumentedSignals'))
                obj.isEmptyInstrumentedSignals=true;
            else
                obj.isEmptyInstrumentedSignals=false;
            end
        end

        function restoreIfEmptyInstrumentedSignals(obj)
            if obj.isEmptyInstrumentedSignals
                set_param(obj.ModelH,'InstrumentedSignals','');
            end
        end
    end

    methods(Access=private)
        function deriveCoverageParam(obj,runtestOpts)
            if~islogical(runtestOpts.coverageEnabled)
                obj.handleMsg('error',message('Sldv:RunTestCase:CoverageEnabledVal',obj.UtilityName));
            elseif runtestOpts.coverageEnabled&&...
                ~isempty(runtestOpts.coverageSetting)&&...
                ~isa(runtestOpts.coverageSetting,'cvtest')
                obj.handleMsg('error',message('Sldv:RunTestCase:CoverageSettingVal',obj.UtilityName));
            end
            obj.GetCoverage=runtestOpts.coverageEnabled;
            obj.CvTestSpec=runtestOpts.coverageSetting;
        end


        function simInput=assignVariablesToSimulationInput(obj,simInput,testIndex)
            SldvParameters=obj.SimDataTimeSeries(testIndex).paramValues;
            for idx=1:length(SldvParameters)
                paramName=SldvParameters(idx).name;
                paramValue=SldvParameters(idx).value;


                if existsInGlobalScope(obj.ModelH,paramName)
                    currentVal=evalinGlobalScope(obj.ModelH,paramName);
                    if isa(currentVal,'Simulink.Parameter')||...
                        isa(currentVal,'mpt.Parameter')



                        paramCopy=currentVal.copy();
                        paramCopy.Value=paramValue;
                        paramValue=paramCopy;
                    end
                end

                simInput=setVariable(simInput,paramName,paramValue);
            end
        end


        function sigInfo=getSigInfo(obj)
            sigInfo=Simulink.SimulationData.SignalLoggingInfo.empty;
            for idx=1:length(obj.PortHsToLog)
                blockPath=get_param(obj.PortHsToLog(idx),'Parent');
                blockOutportHs=get_param(blockPath,'PortHandles').Outport;

                sigIdx=find(blockOutportHs==obj.PortHsToLog(idx));
                sigInfo(idx)=Simulink.SimulationData.SignalLoggingInfo(blockPath,sigIdx);
            end
        end

        outValue=reshapeOutValue(obj,outStruct,loggedData)



        function destroyTmpModel(obj)
            if obj.ModelH~=obj.OrigModelH
                modelToDestroyFileName=get_param(obj.ModelH,'filename');
                Sldv.close_system(obj.ModelH,0);
                delete(modelToDestroyFileName);
            end
        end





        function configureCoverage(obj)
            if obj.GetCoverage
                cvt=cvtest(obj.ModelH);
                if~isempty(obj.CvTestSpec)
                    copySettings(cvt,obj.CvTestSpec);
                end
                obj.CvTestSpec=cvt;
                obj.CvTestSpec.modelRefSettings.excludeTopModel=1;
            end
        end

        function disableSFDebugInParallel(obj,models)%#ok<INUSL>





            for eachModel=models
                m=find(sfroot,'-isa','Stateflow.Machine','Name',eachModel);
                if~isempty(m)
                    m.Debug.Animation.Enabled=0;
                    m.Debug.BreakOn.ChartEntry=0;
                    m.Debug.BreakOn.EventBroadcast=0;
                    m.Debug.BreakOn.StateEntry=0;
                    m.Debug.DisableAllBreakpoints=1;
                    m.Debug.RunTimeCheck.CycleDetection=0;
                    m.Debug.RunTimeCheck.DataRangeChecks=0;
                    m.Debug.RunTimeCheck.StateInconsistencies=0;
                end
            end
        end

        function isDirty=checkDirtyState(obj)


            isDirty=any(arrayfun(@(eachMdl)strcmp(get_param(eachMdl,'Dirty'),'on'),obj.ModelHsInMdlRefTree));
        end

        function outputSaveName=getOutputSaveName(obj,saveFormat)





            outputSaveName=sprintf('yout_%s',obj.UtilityName);

            if strcmp(saveFormat,'Dataset')||numel(obj.OutportBlkHs)<2
                return;
            end


            outputSaveName=repmat({outputSaveName},1,numel(obj.OutportBlkHs));

            outputSaveName=matlab.lang.makeUniqueStrings(outputSaveName);

            outputSaveName=strjoin(outputSaveName,',');
        end

        function data=loadSldvDataFromFile(obj,filePath)

            [~,~,ext]=fileparts(filePath);
            if strcmpi(ext,'.xlsx')||strcmpi(ext,'.xls')
                data.sldvData=Sldv.DataUtils.spreadsheetToSldvData(filePath,obj.ModelH);
            else
                data=load(filePath);
            end
        end

    end

    methods(Access=public,Static)
        function logginNamePrefix=getLoggingPrefix
            logginNamePrefix='dvOutputSignalLogger_';
        end

        function runtestOpts=getRuntestOpts(type)
            if nargin<1
                type='';
            end
            if strcmp(type,'cgv')
                runtestOpts.testIdx=[];
                runtestOpts.allowCopyModel=false;
                runtestOpts.cgvCompType='topmodel';
                runtestOpts.cgvConn='sim';
            else
                runtestOpts.testIdx=[];
                runtestOpts.signalLoggingSaveFormat='Dataset';
                runtestOpts.coverageEnabled=false;
                runtestOpts.coverageSetting=[];
                runtestOpts.fastRestart=true;
                runtestOpts.useParallel=false;
            end
        end

        function msg=iscorrectRuntestOpts(runtestOpts,type)
            if nargin<2
                type='';
            end
            msg='';
            fullRuntestOpts=Sldv.RunTestCase.getRuntestOpts(type);
            if isfield(runtestOpts,'fastRestart')
                fullRuntestOpts.fastRestart=runtestOpts.fastRestart;
            end
            if isfield(runtestOpts,'expectedOutput')
                fullRuntestOpts.expectedOutput=runtestOpts.expectedOutput;
            end
            if isfield(runtestOpts,'useParallel')
                fullRuntestOpts.useParallel=runtestOpts.useParallel;
            end
            if isfield(runtestOpts,'outputFormat')
                fullRuntestOpts.outputFormat='SimulationOutput';
            end
            if strcmp(type,'cgv')&&isfield(runtestOpts,'signalLoggingSaveFormat')
                fullRuntestOpts.signalLoggingSaveFormat='ModelDataLogs';
            end
            acceptableFields=fieldnames(fullRuntestOpts);
            currentfields=fieldnames(runtestOpts);
            if~isempty(setdiff(currentfields,acceptableFields))
                strtmp='';
                for idx=1:length(acceptableFields)-1
                    strtmp=[strtmp,'%s, '];%#ok<AGROW>
                end
                strtmp=[strtmp,getString(message('Sldv:RunTestCase:And')),' %s.'];
                paramNames=sprintf(strtmp,acceptableFields{:});
                msg=getString(message('Sldv:RunTestCase:RuntestOptsMustSpecifyStructure',paramNames));
            end
        end
    end

    methods(Access=protected,Static)
        function hasNoInterpData=nointerpDataType(inputPortInfo,modelH)
            hasNoInterpData=false;
            if~iscell(inputPortInfo)
                hasNoInterpData=sldvshareprivate('util_is_fxp_type',inputPortInfo.DataType,modelH)||...
                strcmp(inputPortInfo.DataType,'double')||...
                strcmp(inputPortInfo.DataType,'single')||...
                sldvshareprivate('util_is_enum_type',inputPortInfo.DataType);
            else
                for i=2:length(inputPortInfo)
                    if Sldv.RunTestCase.nointerpDataType(inputPortInfo{i},modelH)
                        hasNoInterpData=true;
                        break;
                    end
                end
            end
        end

        function varName=findUniqueBaseWSParamName(initialName)
            varName=initialName;
            varList=evalin('base',sprintf('whos(''%s*'')',varName));
            counter=0;
            while true
                if any(strcmp(varName,{varList.name}))
                    varName=horzcat(varName,num2str(counter));%#ok<AGROW>
                    counter=counter+1;
                else
                    break;
                end
            end
        end


        function simInput=assignModelParametersToSimulationInput(simInput,modelParamStruct)
            paramNames=fields(modelParamStruct);
            for paramIdx=1:length(paramNames)
                simInput=setModelParameter(simInput,paramNames{paramIdx},modelParamStruct.(paramNames{paramIdx}));
            end
        end


        function simInput=assignBlockParametersToSimulationInput(simInput,blockParameterStruct)
            for paramIdx=1:length(blockParameterStruct)
                simInput=setBlockParameter(simInput,getfullname(blockParameterStruct(paramIdx).Block),blockParameterStruct(paramIdx).ParameterName,blockParameterStruct(paramIdx).Value);
            end
        end

        function executeInParallel(pool,fh,numOut,varargin)




            parOp=parfevalOnAll(pool,fh,numOut,varargin{:});
            wait(parOp);
            assert(isempty(parOp.Error),'Error on parallel workers');
        end
    end


    methods(Access=public,Hidden)
        function cvtestParamNameValStruct=verifyCvTestToModelParameters(obj,cvTestObj)


            obj.CvTestSpec=cvTestObj;

            cvtestParamNameValStruct=obj.convertCvTestToModelParameters;
        end

        function settings=verifySimManagerConfiguration(obj,model)



            settings=[];
            pool=gcp('nocreate');
            if~isempty(pool)
                obj.Model=model;
                obj.useParallel=true;
                obj.configureSimManager();
                settings.taskingArchFF=fetchOutputs(parfeval(pool,@eval,1,...
                "slfeature('SldvTaskingArchitecture')"));
            end
        end
    end
end


