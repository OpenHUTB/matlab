




classdef SignalLogger<Sldv.SimModel




    properties(Access=protected)


        SldvHarnessModelH=[];



        TopLevelModelH=[];


        SigBlockH=[];


        HarnessSource=[];


        SigBTime=[];



        ModelBlockH=[];


        ModelBlockPath=[];


        RefModelH=[];


        ConvBlockH=[];


        TestUnitBlockH=[];


        LoggedData=[];


        RequiresMexRebuild=false;
    end

    methods
        function obj=SignalLogger(utilityName)
            if nargin<1
                utilityName='sldvlogsignals';
            end

            if~any(strcmp(utilityName,...
                {'sldvlogsignals','slvnvlogsignals','slicerlogsignals'}))
                error(message('Sldv:SignalLogger:UnableToCreateConstructor'));
            end

            obj=obj@Sldv.SimModel;

            if strcmp(utilityName,'slvnvlogsignals')
                invalid=~SlCov.CoverageAPI.checkCvLicense();
                if invalid
                    error(message('Sldv:SignalLogger:SimulinkCoverageNotLicensed'));
                end
                obj.MsgIdPref='Slvnv:LOGSIGNALS:';
            elseif strcmp(utilityName,'slicerlogsignals')
                invalid=~SliceUtils.isSlicerAvailable();
                if invalid

                    error(message('Sldv:SignalLogger:SimulinkDesignVerifierNotLicensed'));
                end
                obj.MsgIdPref='Sldv:LOGSIGNALS:';
            else
                invalid=builtin('_license_checkout','Simulink_Design_Verifier','quiet');
                if invalid
                    error(message('Sldv:SignalLogger:SimulinkDesignVerifierNotLicensed'));
                end
                obj.MsgIdPref='Sldv:LOGSIGNALS:';
            end

            obj.SignalLoggerPrefix='dvInputSignalLogger_';
            obj.UtilityName=utilityName;
        end

        data=logInputSignals(obj,varargin);

    end

    methods(Access=protected)
        function resetSessionData(obj)
            obj.restoreLoggers(obj.RefModelH);
            if obj.RequiresMexRebuild
                obj.invokeMexRebuild;
            end


            Sldv.utils.manageAliasTypeCache('clear');

            resetSessionData@Sldv.SimModel(obj);
        end

        function storeOriginalModelParams(obj)
            if obj.isNoModelRef
                topLevelModelH=obj.SldvHarnessModelH;
                refModelH=[];
            else
                topLevelModelH=obj.TopLevelModelH;
                refModelH=obj.RefModelH;
            end

            obj.ModelHsNormalMode=topLevelModelH;
            obj.ModelHsInMdlRefTree=topLevelModelH;
            topLevelModelName=get_param(topLevelModelH,'Name');
            obj.DirtyStatus.(topLevelModelName)=get_param(topLevelModelH,'Dirty');
            obj.findBlocksInMdlRefTree(topLevelModelH);

            if~isempty(refModelH)
                settingsCache.MdlBlkSimulationMode=get_param(obj.ModelBlockH,'SimulationMode');
            end

            settingsCache.OldConfigSet=getActiveConfigSet(topLevelModelH);
            settingsCache.ModelLoggingInfo=get_param(topLevelModelH,'DataLoggingOverride');

            obj.SettingsCache=settingsCache;
        end

        function invokeMexRebuild(obj)
            refmodel=get_param(obj.RefModelH,'Name');
            slbuild(refmodel,'ModelReferenceSimTarget',...
            'UpdateThisModelReferenceTarget','IfOutOfDateOrStructuralChange');
        end

        function restoreOriginalModelParams(obj)
            if~isempty(obj.SettingsCache)
                set_param(obj.ModelHsInMdlRefTree(1),'DataLoggingOverride',obj.SettingsCache.ModelLoggingInfo);
                Sldv.utils.restoreConfigSet(obj.ModelHsInMdlRefTree(1),obj.SettingsCache.OldConfigSet);
                if~isempty(obj.ModelBlockH)
                    set_param(obj.ModelBlockH,'SimulationMode',...
                    obj.SettingsCache.MdlBlkSimulationMode);
                end
                obj.restoreDirtyStatus;
                obj.SettingsCache=[];
            end
        end

        derivePortHandlesToLog(obj)

        changeModelParameters(obj)

        setModelLoggingInfo(obj)

        configureLoggers(obj,modelHIncludingLoggers);

        cacheExistingLoggers(obj)

        function initForSim(obj)
            topLevelModelH=obj.ModelHsInMdlRefTree(1);

            Sldv.utils.replaceConfigSetRefWithCopy(topLevelModelH);


            obj.changeModelParameters;

            if~isempty(obj.ModelBlockH)
                if~any(strcmp(get_param(obj.ModelBlockH,'SimulationMode'),...
                    {'Accelerator','Normal'}))
                    set_param(obj.ModelBlockH,'SimulationMode','Normal');
                end


                obj.configureLoggers(obj.RefModelH);

                if obj.RequiresMexRebuild

                    obj.invokeMexRebuild;
                end
            else

                obj.configureLoggers;
            end


            obj.setModelLoggingInfo;



            set_param(topLevelModelH,'Dirty','off');
        end

        function warningIds=listWarningsToTurnForLogging(obj)
            warningIds={};
            warningIds{end+1}={'Simulink:Logging:SigLogIdentifier'};
            warningIds{end+1}={'Simulink:Engine:OutportCannotLogNonBuiltInDataTypes'};
            warningIds{end+1}={'Simulink:Commands:SetParamLinkChangeWarn'};
            warningIds{end+1}={'backtrace'};
            if isa(obj,'Sldv.SubsystemLogger')
                warningIds{end+1}={'Simulink:Logging:TopMdlOverrideUpdated'};
            end
        end

        function paramNameValStruct=getBaseSimStruct(obj)
            paramNameValStruct.StartTime='0.0';
            paramNameValStruct.AssertControl='DisableAll';




            paramNameValStruct.ModelReferenceCSMismatchMessage='none';
            paramNameValStruct.UpdateModelReferenceTargets='IfOutOfDate';
            paramNameValStruct.CovSFcnEnable='off';
            paramNameValStruct.SignalLoggingName=obj.ModelLogger;
            paramNameValStruct.SignalLogging='on';

            if~isa(obj,'Sldv.SubsystemLogger')
                paramNameValStruct.SFSimEnableDebug='off';
                paramNameValStruct.RecordCoverage='off';
                paramNameValStruct.CovModelRefEnable='off';
                paramNameValStruct.CovExternalEMLEnable='off';
                paramNameValStruct.CovSFcnEnable='off';
            else

                paramNameValStruct.RecordCoverage='on';
                paramNameValStruct.CovModelRefEnable='on';
                paramNameValStruct.CovExternalEMLEnable='on';
                paramNameValStruct.CovSFcnEnable='on';
                paramNameValStruct.DSMLogging='on';
                paramNameValStruct.DSMLoggingName='dsmOut';
            end
        end

        function paramNameValStruct=modifySimstruct(obj,testIndex,paramNameValStruct)
            stopTime=obj.SigBTime{1,testIndex}(end);
            paramNameValStruct.StopTime=sldvshareprivate('util_double2str',stopTime);
        end

        runTests(obj)
    end

    methods(Access=protected)
        function out=isNoModelRef(obj)
            out=~isempty(obj.ConvBlockH)&&isempty(obj.ModelBlockH);
        end

        function deriveConvBlockH(obj)
            if~isempty(obj.SldvHarnessModelH)
                assert(~isempty(obj.SigBlockH));
                sigBportHandles=get_param(obj.SigBlockH,'PortHandles');
                try
                    lineH=get_param(sigBportHandles.Outport(1),'Line');
                    convBlock=get_param(get_param(lineH,'DstPortHandle'),'Parent');
                    objH=Sldv.utils.getObjH(convBlock);
                    obj.ConvBlockH=objH;
                catch Mex
                    obj.handleMsg('error',message('Sldv:SignalLogger:MissingSizeType',getfullname(obj.SldvHarnessModelH),Mex.message));
                end
            end
        end

        function deriveTestUnitBlockH(obj)
            if~isempty(obj.SldvHarnessModelH)
                assert(~isempty(obj.ConvBlockH));
                if isempty(obj.ModelBlockH)
                    convPortHandles=get_param(obj.ConvBlockH,'PortHandles');
                    testUnitBlock={};
                    try
                        lineH=get_param(convPortHandles.Outport(1),'Line');
                        testUnitBlock=get_param(get_param(lineH,'DstPortHandle'),'Parent');
                    catch Mex
                        obj.handleMsg('error',message('Sldv:SignalLogger:MissingTestUnit',getfullname(obj.SldvHarnessModelH),Mex.message))
                    end
                    if~iscell(testUnitBlock)
                        testUnitBlock={testUnitBlock};
                    end
                    if length(testUnitBlock)>1
                        obj.handleMsg('error',message('Sldv:SignalLogger:SpecifyModelBlock',get_param(obj.SldvHarnessModelH,'Name'),obj.UtilityName));
                    else
                        objH=Sldv.utils.getObjH(testUnitBlock{1});
                        obj.TestUnitBlockH=objH;
                    end
                else
                    obj.TestUnitBlockH=obj.ModelBlockH;
                end
            end
        end

        function checkImplicitModelRefHarness(obj)
            if isempty(obj.ModelBlockH)&&...
                ~isempty(obj.SldvHarnessModelH)&&...
                strcmp(get_param(obj.TestUnitBlockH,'BlockType'),'ModelReference')
                obj.ModelBlockH=obj.TestUnitBlockH;


                obj.ModelBlockPath=Simulink.BlockPath(getfullname(obj.ModelBlockH));
            elseif~isempty(obj.ModelBlockH)&&...
                ~isempty(obj.SldvHarnessModelH)&&...
                (isempty(obj.TestUnitBlockH)||obj.ModelBlockH~=obj.TestUnitBlockH)
                obj.handleMsg('error',message('Sldv:SignalLogger:ModelBlockSldvHarness',getfullname(obj.ModelBlockH)));
            end
        end

        function checkImplicitTcIdx(obj)
            if~isempty(obj.SldvHarnessModelH)&&isempty(obj.TcIdx)
                assert(~isempty(obj.SigBlockH));
                numTestCases=obj.HarnessSource.getNumberOfTestcases;
                obj.TcIdx=1:numTestCases;
            end
        end

        function deriveReferencedModelH(obj)
            if~isempty(obj.ModelBlockH)
                referencedModelName=get_param(obj.ModelBlockH,'ModelName');
                isLoaded=bdIsLoaded(referencedModelName);
                if~isLoaded
                    Sldv.load_system(referencedModelName);
                    obj.MdlLoaded{end+1}=referencedModelName;
                end
                obj.RefModelH=get_param(referencedModelName,'Handle');
                inBlkHs=Sldv.utils.getSubSystemPortBlks(obj.RefModelH);
                if isempty(inBlkHs)
                    obj.handleMsg('error',message('Sldv:SignalLogger:NoInportsOnRefModel'));
                end
            end
        end

        function checkForArrayOfBuses(obj)
            if(~isempty(obj.RefModelH))
                portnames=Sldv.utils.containsArrayOfBuses(obj.RefModelH);
                if(~isempty(portnames))
                    errStr=getString(message('Sldv:SignalLogger:MultidimBusTypesOnInports'));
                    for idx=1:length(portnames)
                        if(idx==1)
                            errStr=[errStr,sprintf('%s',portnames{idx})];%#ok<AGROW>
                        else
                            errStr=[errStr,sprintf(', %s',portnames{idx})];%#ok<AGROW>
                        end
                    end
                    errStr=[errStr,' ',getString(message('Sldv:SignalLogger:AreNotSupported'))];
                    obj.handleMsg('error','Sldv:SignalLogger:UnsupInportType',errStr);
                end
            end
        end

        function checkRefModelSolverType(obj)
            if~isempty(obj.RefModelH)
                modelOb=get_param(obj.RefModelH,'Object');
                modelObAcs=modelOb.getActiveConfigSet;
                modelSolverType=modelObAcs.getProp('SolverType');
                if strcmp(modelSolverType,'Variable-step')
                    obj.handleMsg('error',message('Sldv:SignalLogger:VarStepRefModel'));
                end
            end
        end

        function checkRefModelSampleTimes(obj,sampleTimeInformation)
            if~isempty(obj.RefModelH)
                for idx=1:length(sampleTimeInformation)
                    if all(size(sampleTimeInformation(idx).Value)==[1,2])&&...
                        ~(sampleTimeInformation(idx).Value(1)==Inf)&&...
                        sampleTimeInformation(idx).Value(1)>0&&...
                        sampleTimeInformation(idx).Value(2)>0



                        obj.handleMsg('error',message('Sldv:SignalLogger:NonZeroOffsetRefModel'));
                    end
                end
            end
        end

        function checkForComplexType(obj,sldvData)
            if(~isempty(obj.RefModelH))
                portnames=Sldv.DataUtils.hasComplexTypeInports(sldvData,obj.RefModelH);
                if(~isempty(portnames))
                    errStr=getString(message('Sldv:SignalLogger:ComplexTypesOnInports'));
                    for idx=1:length(portnames)
                        if(idx==1)
                            errStr=[errStr,sprintf('"%s"',portnames{idx})];%#ok<AGROW>
                        else
                            errStr=[errStr,sprintf(', "%s"',portnames{idx})];%#ok<AGROW>
                        end
                    end
                    errStr=[errStr,' ',getString(message('Sldv:SignalLogger:AreNotSupported'))];
                    obj.handleMsg('error','Sldv:SignalLogger:UnsupInportType',errStr);
                end
            end
        end

        function checkStartTimeTopLevel(obj)
            startTime=get_param(obj.TopLevelModelH,'StartTime');
            actualStartTime=[];
            try
                actualStartTime=eval(startTime);
            catch Mex %#ok<NASGU>
            end
            if isempty(actualStartTime)
                try
                    actualStartTime=evalin('base',startTime);
                catch Mex %#ok<NASGU>
                end
            end
            if isempty(actualStartTime)
                try
                    topMdlWs=get_param(obj.TopLevelModelH,'modelworkspace');
                    actualStartTime=topMdlWs.evalin(startTime);
                catch Mex %#ok<NASGU>
                end
            end
            assert(~isempty(actualStartTime));
            if actualStartTime~=0
                obj.handleMsg('error',message('Sldv:SignalLogger:NonZeroStartTime',get_param(obj.TopLevelModelH,'Name')));
            end
        end

        function loadHarnessGeneratedMdl(obj)
            if~isempty(obj.SldvHarnessModelH)&&isempty(obj.ModelBlockH)
                modelNameHarnessGenerated=...
                Sldv.HarnessUtils.getGeneratedModel(obj.SldvHarnessModelH);
                isLoaded=bdIsLoaded(modelNameHarnessGenerated);
                if~isLoaded
                    errorStr='';
                    try
                        Sldv.load_system(modelNameHarnessGenerated);
                        obj.MdlLoaded{end+1}=modelNameHarnessGenerated;
                    catch Mex
                        errorStr=Mex.message;
                    end
                    if~isempty(errorStr)
                        obj.handleMsg('error',message('Sldv:SignalLogger:SldvHarnessGenModeNotLoaded',...
                        get_param(obj.SldvHarnessModelH,'Name'),...
                        modelNameHarnessGenerated,...
                        obj.UtilityName,...
                        modelNameHarnessGenerated,errorStr));
                    end
                end
            end
        end

        function generateErrorMessageForLogger(obj)
            if~isempty(obj.ModelBlockH)
                obj.handleMsg('error',message('Sldv:SignalLogger:UnableToLog',getfullname(obj.ModelBlockH)));
            else
                obj.handleMsg('error',message('Sldv:SignalLogger:UnableToLog1',getfullname(obj.TestUnitBlockH)));
            end
        end

        currentTest=deriveFunctionalTestCase(obj,topLevelLogger,tcIdx);

        [sldvData,sampleTimeInformation]=generateDataForLogging(obj);

        convertLoggedDataToCellFormat(obj,sldvDataTs);
    end
end


