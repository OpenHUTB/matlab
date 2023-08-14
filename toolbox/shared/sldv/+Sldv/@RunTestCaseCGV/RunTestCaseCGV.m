




classdef RunTestCaseCGV<Sldv.RunTestCase






    properties(Access=private)

        AllowCopyModel=false;


        CgvType='topmodel';



        CgvModeOfExecution='sim';



        CGVModelPath='';


        CGVModelH=[];


        CGVModel='';



        KeepOutputFiles=false;




        ParamNameValStruct=[];


        LineNamePrefix='';



        BaseWSStopTimeName='';



        OutputDir='';


        CGVFullOutputDir='';



        CGVMATFileInput={};



        OriginalFolder='';


        OriginalFolderInPath=false;


        CGVObj=[];




        BaseWSSimulinkParameters=[];



        ModelInOutInterfaceAcceptable=true;



        BaseWSParamRestored=false;



        ModelConfiguredCorrectlyForCGV=true;
    end

    properties(Access=private,Dependent)


        ModelToExe='';
    end

    methods
        function obj=RunTestCaseCGV(utilityName)
            if nargin<1
                utilityName='sldvruncgvtest';
            end
            if~any(strcmp(utilityName,...
                {'sldvruncgvtest','slvnvruncgvtest'}))
                error(message('Sldv:RunTestCaseCGV:UnableToCreateConstructor'));
            end
            if isempty(meta.package.fromName('cgv'))||...
                exist('cgv.Config','class')~=8||...
                exist('cgv.CGV','class')~=8
                error(message('Sldv:RunTestCaseCGV:CGVAPINotInstalled'));
            end
            isvnvmode=strcmp(utilityName,'slvnvruncgvtest');
            obj=obj@Sldv.RunTestCase(utilityName,isvnvmode,false);
            if isvnvmode
                obj.MsgIdPref='Slvnv:RUNTESTCGV:';
            else
                obj.MsgIdPref='Sldv:RUNTESTCGV:';
            end
            obj.SignalLoggerPrefix=Sldv.RunTestCaseCGV.getLoggingPrefix;
            obj.LineNamePrefix='cgv_runtest_out_';
            obj.ModelLogger=sprintf('logsout_%s',utilityName);
            obj.BaseWSStopTimeName=obj.findUniqueBaseWSParamName('testCaseStopTime');
            obj.BaseWSSldvDataName=obj.findUniqueBaseWSParamName('testCase');
            obj.OutputDir='cgv_runtest/$ModelName$';
        end

        varargout=simTestCases(obj,model,sldvData,varargin);


        function value=get.ModelToExe(obj)
            if~isempty(obj.CGVModel)
                value=obj.CGVModel;
            else
                value=obj.Model;
            end
        end
    end

    methods(Access=protected)
        function deriveModelParam(obj,model)
            deriveModelParam@Sldv.RunTestCase(obj,model);


            refMdls=find_mdlrefs(obj.Model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            for idx=1:length(refMdls)
                if bdIsLoaded(refMdls{idx})
                    if strcmp(get_param(obj.ModelH,'Dirty'),'on')
                        obj.handleMsg('error',message('Sldv:RunTestCaseCGV:InvalidFirstInputModelDirty',obj.UtilityName,refMdls{idx}));
                    end
                end
            end
        end

        function deriveSldvDataParam(obj,sldvData)
            if ischar(sldvData)||isstring(sldvData)
                rawdata=load(sldvData);
                dataFields=fields(rawdata);
                if length(dataFields)==1
                    sldvData=rawdata.(dataFields{1});
                else
                    obj.handleMsg('error',message('Sldv:RunTestCaseCGV:InvalidDataFormat1',obj.UtilityName));
                end
            end

            sldvData=...
            Sldv.DataUtils.convertToCurrentFormat(obj.ModelH,sldvData);

            obj.SldvData=sldvData;

            simData=Sldv.DataUtils.getSimData(obj.SldvData);
            if isempty(simData)
                obj.handleMsg('error',message('Sldv:RunTestCaseCGV:NoTestCase'));
            end
        end

        checkSldvData(obj,modelToCheck)

        function resetSessionData(obj)
            if~obj.KeepOutputFiles

                if~isempty(obj.CGVModelPath)&&~isempty(obj.CGVModel)&&...
                    any(exist(obj.CGVModelPath,'file')==[2,4])
                    if~isempty(obj.CGVModelH)&&...
                        ishandle(obj.CGVModelH)
                        Sldv.RunTestCaseCGV.termModel(obj.CGVModelH);
                        Sldv.close_system(obj.CGVModelH,0);
                    elseif~isempty(obj.CGVModel)&&...
                        bdIsLoaded(obj.CGVModel)
                        Sldv.RunTestCaseCGV.termModel(obj.CGVModel);
                        Sldv.close_system(obj.CGVModel,0);
                    end
                    delete(obj.CGVModelPath);
                    obj.CGVModelPath='';
                    obj.CGVModelH=[];
                    obj.CGVModel='';
                end
                for idx=1:length(obj.CGVMATFileInput)
                    if~isempty(obj.CGVMATFileInput{idx})&&...
                        exist(obj.CGVMATFileInput{idx},'file')==2
                        delete(obj.CGVMATFileInput{idx});
                    end
                end
            elseif~isempty(obj.CGVModel)&&...
                ~strcmp(obj.CGVModel,obj.Model)
                Sldv.close_system(obj.CGVModel,0);
            end


            Sldv.utils.getBusObjectFromName(-1);


            Sldv.utils.manageAliasTypeCache('clear');

            obj.restoreBaseWorkspaceVars;
            obj.reverseOutputDir;
            obj.restoreWarningStatus;
            obj.restoreLoadedModels;
            obj.restoreAutoSaveState;
        end

        derivePortHandlesToLog(obj)

        configureLoggers(obj,modelHIncludingLoggers)


        function restoreBaseWorkspaceVars(obj)
            if~obj.BaseWSParamRestored
                if~isempty(obj.BaseWSParamsCached)

                    originalVars={obj.BaseWSParamsCached.name};
                    newBaseVars=evalin('base','who');
                    addedVars=setdiff(newBaseVars,originalVars);
                    clearCmd=['clear ',sprintf('%s ',addedVars{:})];
                    evalin('base',clearCmd);
                    for idx=1:length(obj.BaseWSParamsCached)
                        assignin('base',obj.BaseWSParamsCached(idx).name,obj.BaseWSParamsCached(idx).value);
                    end
                    obj.BaseWSParamsCached=[];
                else
                    newBaseVars=evalin('base','who');
                    clearCmd=['clear ',sprintf('%s ',newBaseVars{:})];
                    evalin('base',clearCmd);
                end
                obj.BaseWSParamRestored=true;
            end
        end

        function cacheBaseWorkspaceVars(obj)
            baseVars=evalin('base','who');
            if~isempty(baseVars)
                paramsCached(1:length(baseVars))=struct('name','','value',[]);
                for idx=1:length(baseVars)
                    origParamInfo.name=baseVars{idx};
                    origParamInfo.value=evalin('base',baseVars{idx});
                    paramsCached(idx)=origParamInfo;
                end
            else
                paramsCached=[];
            end
            obj.BaseWSParamsCached=paramsCached;
        end

        function str=genExternalInputStrForTestCase(obj,~)
            str=obj.BaseWSSldvDataName;
        end

        runTests(obj)

        function warningIds=listWarningsToTurnForLogging(obj)
            warningIds={};
            if any(strcmp(obj.OutputFormat,{'TimeSeries','SimulationOutput'}))
                warningIds{end+1}={'Simulink:SL_OutportCannotLogNonBuiltInDataTypes'};
            end


            warningIds{end+1}={'backtrace'};
        end

        function deriveNonCGVParams(obj,runtestOpts)
            deriveNonCGVParams@Sldv.RunTestCase(obj,runtestOpts);
            if strcmp(obj.SignalLoggingSaveFormat,'Dataset')
                obj.handleMsg('error',message('Sldv:RunTestCaseCGV:SignalLoggingSaveFormatVal',obj.UtilityName));
            end
        end
    end

    methods(Access=private)
        deriveCGVParams(obj,runtestOpts)


        createCGVModel(obj)



        checkModelInOutInterface(obj)







        function reportModelInOutIncompatiblity(obj,msg,msgId)
            obj.ModelInOutInterfaceAcceptable=false;
            if obj.AllowCopyModel
                msgwarning=getString(message('Sldv:RunTestCaseCGV:ModelWillBeCopied',obj.Model));
                msg=[msg,msgwarning];
                obj.handleMsg('warning',msgId,msg);
            else
                obj.handleMsg('error',msgId,msg);
            end
        end

        createCopyCGVModel(obj)


        function setCGVOutputDir(obj)
            if obj.ModelInOutInterfaceAcceptable&&...
                obj.ModelConfiguredCorrectlyForCGV
                obj.CGVFullOutputDir=fileparts(obj.CGVMATFileInput{1});
            end
        end

        function cgvCfg=createCGVConfigObj(obj,cgvSaveModel)
            if any(strcmp(obj.OutputFormat,{'TimeSeries','SimulationOutput'}))
                cgvLogMode='SignalLogging';
            else
                cgvLogMode='SaveOutput';
            end
            if strcmp(cgvSaveModel,'off')
                cgvReportOnly='on';
            else
                cgvReportOnly='off';
            end
            cgvCfg=cgv.Config(obj.ModelToExe,...
            'ComponentType',obj.CgvType,...
            'connectivity',obj.CgvModeOfExecution,...
            'LogMode',cgvLogMode,...
            'ReportOnly',cgvReportOnly,...
            'SaveModel',cgvSaveModel,...
            'Checkoutports','off');
        end

        function cgvObj=createCGVObj(obj)
            obj.KeepOutputFiles=true;

            if~obj.ModelInOutInterfaceAcceptable||...
                ~obj.ModelConfiguredCorrectlyForCGV

                obj.OriginalFolder=pwd;
                currpath=evalin('base','path');
                obj.OriginalFolderInPath=...
                ~isempty(strfind([currpath,';'],[obj.OriginalFolder,';']));
                if~obj.OriginalFolderInPath
                    addpath(obj.OriginalFolder);
                end
                cd(obj.CGVFullOutputDir);
            end

            cgvObj=cgv.CGV(obj.ModelToExe,...
            'ComponentType',obj.CgvType,...
            'connectivity',obj.CgvModeOfExecution);
            cgvObj.setOutputDir(obj.CGVFullOutputDir);
            cgvObj.setSimParams(obj.ParamNameValStruct);
            numTestCases=length(obj.TcIdx);
            for idx=1:numTestCases
                cgvObj.addInputData(idx,obj.CGVMATFileInput{idx});
            end
        end

        function checkCGVConfig(obj)
            cgvCfg=obj.createCGVConfigObj('off');
            cgvCfg.configModel();
            if~isempty(cgvCfg.Changes)
                cgvCfg.displayReport;
                obj.ModelConfiguredCorrectlyForCGV=false;
                if obj.AllowCopyModel
                    obj.handleMsg('warning',message('Sldv:RunTestCaseCGV:NotConfiguredCorrectlyForCGV',obj.Model));
                else
                    obj.handleMsg('error',message('Sldv:RunTestCaseCGV:NotConfiguredCorrectlyForCGV1',obj.Model));
                end
            end
        end

        function getSimStructForRunTest(obj)
            modelToExeH=get_param(obj.ModelToExe,'Handle');

            paramNameValStruct.StartTime='0.0';
            paramNameValStruct.StopTime=obj.BaseWSStopTimeName;
            paramNameValStruct.SimulationMode=obj.getSimulationMode;

            paramNameValStruct.GenerateReport='off';
            paramNameValStruct.AssertControl='DisableAll';
            paramNameValStruct.InheritedTsInSrcMsg='none';
            paramNameValStruct.RTWVerbose='off';





            paramNameValStruct.ModelReferenceCSMismatchMessage='none';
            paramNameValStruct.UpdateModelReferenceTargets='IfOutOfDate';

            paramNameValStruct.SFSimEnableDebug='off';
            paramNameValStruct.RecordCoverage='off';
            paramNameValStruct.CovModelRefEnable='off';
            paramNameValStruct.CovExternalEMLEnable='off';
            paramNameValStruct.CovSFcnEnable='off';

            if sldvshareprivate('mdl_issampletimeindep',modelToExeH)
                paramNameValStruct.SampleTimeConstraint='Unconstrained';
            end
            if~strcmp(get_param(modelToExeH,'SampleTimeConstraint'),'Specified')
                paramNameValStruct.FixedStep=sldvshareprivate('util_double2str',obj.FunTs);
            end

            paramNameValStruct.LoadExternalInput='on';
            paramNameValStruct.ExternalInput=obj.genExternalInputStrForTestCase(1);
            if sldvshareprivate("mdl_check_rootlvl_buselemport",modelToExeH)


                paramNameValStruct.SaveFormat='Dataset';
            else
                paramNameValStruct.SaveFormat='StructureWithTime';
            end
            paramNameValStruct.SaveTime='on';
            paramNameValStruct.TimeSaveName=sprintf('tout_%s',obj.UtilityName);
            paramNameValStruct.SaveState='on';
            paramNameValStruct.StateSaveName=sprintf('xout_%s',obj.UtilityName);
            paramNameValStruct.SaveOutput='on';
            paramNameValStruct.OutputSaveName=sprintf('yout_%s',obj.UtilityName);
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

            obj.ParamNameValStruct=paramNameValStruct;
        end

        function mode=getSimulationMode(obj)
            switch obj.CgvModeOfExecution
            case 'sim'
                mode='normal';
            case 'sil'
                mode='software-in-the-loop (sil)';
            case 'pil'
                mode='processor-in-the-loop (pil)';
            otherwise
                obj.handleMsg('error',message('Sldv:RunTestCaseCGV:UnknownCGVMode'));
            end
        end

        insertLineNames(obj)




        updateOutports(obj)



        prepareInputDataForCGVObj(obj)



        getInputMATFilePaths(obj)



        function reverseOutputDir(obj)
            if~isempty(obj.OriginalFolder)
                if~obj.OriginalFolderInPath
                    rmpath(obj.OriginalFolder);
                end
                cd(obj.OriginalFolder);
                obj.OriginalFolder='';
            end
        end

        findBaseWSSimulinkParameters(obj)



    end

    methods(Access=public,Static)
        function logginNamePrefix=getLoggingPrefix
            logginNamePrefix='cgvOutputSignalLogger_';
        end
    end

    methods(Access=private,Static)
        function termModel(mdl)
            if~isempty(mdl)
                valuePaused=strcmp(get_param(mdl,'SimulationStatus'),'paused');
            else
                valuePaused=false;
            end
            if valuePaused
                mdlName=get_param(mdl,'Name');%#ok<NASGU>
                evalc('feval(mdlName,[],[],[],''term'');');
            end
        end
    end
end
