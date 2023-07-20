classdef Extract<handle




    properties(Access=protected)

        OrigModelH=[];


        ShowModel=true;


        ShowUI=false;


        IsValid=false;


        UtilityName='';


        MsgIdPref='';


        PhaseId=0;


        Status=true;


        ModelH=[];


        BlockH=[];


        ErrMsg='';


        OriginalWarningStatus={}


        SldvExist=false;


        ExtractionMode=0;


        IsModelSlicer=false;



        Opts=[];
    end

    methods
        function obj=Extract(utilityName)
            if nargin<1
                utilityName='sldvextract';
            end

            if~any(strcmp(utilityName,...
                {'sldvextract','slvnvextract','stmextract','slicerextract'}))
                error(message('Sldv:SubSysExtract:UnableToCreateConstructor'));
            end

            isInAnalysisForFPT=sldvshareprivate('util_is_analyzing_for_fixpt_tool');
            isInAnalysisForSlicer=false;

            if strcmp(utilityName,'slvnvextract')
                invalid=~SlCov.CoverageAPI.checkCvLicense();
                if invalid
                    error(message('Sldv:SubSysExtract:SimulinkCoverageNotLicensed'));
                end
                obj.MsgIdPref='Slvnv:EXTRACT:';
                obj.ExtractionMode=1;
            elseif strcmp(utilityName,'stmextract')
                obj.MsgIdPref='STM:EXTRACT:';
                obj.ExtractionMode=1;
            elseif strcmp(utilityName,'slicerextract')
                isInAnalysisForSlicer=true;
                invalid=~SliceUtils.isSlicerAvailable();
                if invalid

                    error(message('Sldv:SubSysExtract:SimulinkDesignVerifierNotLicensed'));
                end
                obj.MsgIdPref='Sldv:EXTRACT:';
                obj.ExtractionMode=0;
            else
                if~isInAnalysisForFPT
                    invalid=builtin('_license_checkout','Simulink_Design_Verifier','quiet');
                    if invalid
                        error(message('Sldv:SubSysExtract:SimulinkDesignVerifierNotLicensed'));
                    end
                end

                obj.MsgIdPref='Sldv:EXTRACT:';
                obj.ExtractionMode=0;
            end

            obj.UtilityName=utilityName;
            obj.SldvExist=isInAnalysisForSlicer||...
            isInAnalysisForFPT||(license('test','Simulink_Design_Verifier')&&exist('slavteng','builtin')==5);
        end


        function varargout=extract(obj,block,varargin)
            obj.BlockH=Sldv.utils.getObjH(block,true);
            if isempty(obj.BlockH)


                msg=getString(message('Sldv:SubSysExtract:InvalidFirstArg',obj.UtilityName));
                msgid='Sldv:SubSysExtract:InvalidFirstArg';

                obj.setExtractError(msg,msgid);
                obj.Status=false;
                obj.ModelH=[];
            end

            if obj.Status
                obj.OrigModelH=bdroot(obj.BlockH);
                obj.Opts=obj.validateExtractArgs(varargin{:});


                obj.PhaseId=1;


                [obj.ModelH,~,error_occ,extractExc]=Simulink.harness.internal.extractSubsystem(obj.BlockH);

                if error_occ
                    msg=getString(message('Sldv:SubSysExtract:InvalidFirstArg',obj.UtilityName));
                    msgid='Sldv:SubSysExtract:InvalidFirstArg';

                    obj.setExtractError(msg,msgid);
                    obj.Status=false;
                    obj.ModelH=[];
                    obj.deriveErrorMsg(extractExc);
                else
                    origBlockName=get_param(obj.BlockH,'Name');
                    obj.renameExtractedBlock(origBlockName);
                    obj.saveExtractedModel;
                end
            end

            varargout{1}=obj.Status;
            varargout{2}=obj.ModelH;
            varargout{3}=obj.ErrMsg;
        end
    end

    methods(Access=protected,Static)


        status=checkIsActive(blockH);
    end

    methods(Access=protected)
        function opts=validateExtractArgs(obj,varargin)
            nargs=nargin-1;
            showModel=varargin{1};
            opts=[];
            obj.IsModelSlicer=false;
            if nargs==1
                showUI=false;
                isValid=false;
            elseif nargs==2
                showUI=varargin{2};
                isValid=false;
            elseif nargs==3
                showUI=varargin{2};
                isValid=varargin{3};
            elseif nargs==4
                showUI=varargin{2};
                isValid=varargin{3};
                opts=varargin{4};
            else
                showUI=varargin{2};
                isValid=varargin{3};
                opts=varargin{4};
                obj.IsModelSlicer=varargin{5};
            end

            if~islogical(showModel)
                obj.handleMsg('error',message('Sldv:SubSysExtract:InvalidShowModel',obj.UtilityName));
            end
            obj.ShowModel=showModel;

            if~islogical(showUI)
                obj.handleMsg('error',message('Sldv:SubSysExtract:InvalidShowUI',obj.UtilityName));
            end
            obj.ShowUI=showUI;

            if~islogical(isValid)
                obj.handleMsg('error',message('Sldv:SubSysExtract:InvalidIsValid',obj.UtilityName));
            end
            obj.IsValid=isValid;
        end











        function handleMsg(~,msgOpt,varargin)
            if nargin==3
                switch msgOpt
                case 'warning'
                    sldvshareprivate('util_gen_warning_notrace',varargin{1}.Identifier,getString(varargin{1}));
                case 'error'
                    error(varargin{1});
                otherwise
                    assert(false,getString(message('Sldv:SubSysExtract:UnexpectedMsgValue')));
                end
            else
                switch msgOpt
                case 'warning'
                    sldvshareprivate('util_gen_warning_notrace',varargin{1},varargin{2},varargin{3:end});
                case 'error'
                    error(varargin{1},varargin{2},varargin{3:end});
                otherwise
                    assert(false,getString(message('Sldv:SubSysExtract:UnexpectedMsgValue')));
                end
            end
        end

        function warningIds=listWarningsToTurnOFF(obj)
            warningIds={};
            if obj.PhaseId==1
                warningIds{end+1}={'RTW:buildProcess:MatFileLoggingNotSupportedFcnCallErr'};
                warningIds{end+1}={'RTW:buildProcess:ICHandShakingAcrossSSInportNotSupported'};
                warningIds{end+1}={'RTW:buildProcess:ICHandShakingAcrossSSOutportNotSupported'};
            elseif obj.PhaseId==2
                warningIds{end+1}={'Simulink:SL_SaveWithDisabledLinks_Warning'};
            end
            warningIds{end+1}={'backtrace'};
        end


        function turnOffAndStoreWarningStatus(obj)
            warningIds=obj.listWarningsToTurnOFF;
            warningStatus=cell(1,length(warningIds));
            for i=1:length(warningIds)
                warningStatus{i}=warning('query',char(warningIds{i}));
                warning('off',char(warningIds{i}));
            end
            obj.OriginalWarningStatus=warningStatus;
        end

        function restoreWarningStatus(obj)
            if~isempty(obj.OriginalWarningStatus)
                warningIds=obj.listWarningsToTurnOFF;
                warningStatus=obj.OriginalWarningStatus;
                for i=1:length(warningIds)
                    warning(warningStatus{i}.state,char(warningIds{i}));
                end
                obj.OriginalWarningStatus={};
            end
        end

        function deriveErrorMsg(obj,errMsg,addIntermediateCauses)
            if nargin<3
                addIntermediateCauses=false;
            end
            sldvshareprivate('avtcgirunsupcollect','clear');
            mExceptionCauseFlat=sldvshareprivate('util_get_error_causes',errMsg,addIntermediateCauses);
            sldvshareprivate('util_add_error_causes',obj.OrigModelH,mExceptionCauseFlat);
            obj.ErrMsg=sldvshareprivate('avtcgirunsupdialog',obj.OrigModelH,obj.ShowUI);
        end

        function setExtractError(obj,msg,msgId)
            obj.ErrMsg.msgid=msgId;
            obj.ErrMsg.msg=msg;
        end

        function[extractedModelFullPath,testcomp,opts]=getExtractionInfo(obj,extractedModelName,modelH)
            extractedModelFullPath=[];
            if obj.SldvExist
                testcomp=Sldv.Token.get.getTestComponent;
                if~isempty(testcomp)
                    opts=testcomp.activeSettings;
                else
                    if~isempty(obj.Opts)
                        opts=obj.Opts.deepCopy;
                    else
                        opts=sldvoptions;
                        opts.OutputDir='.';
                    end
                end
            else
                testcomp=[];
                opts=sldvdefaultoptions;
                opts.OutputDir='.';
            end

            if~obj.IsModelSlicer
                extractedModelName=ensureNoConflictingVar(modelH,extractedModelName);

                set_param(obj.ModelH,'Name',extractedModelName);
                extractedModelFullPath=deriveExtractedModelName(extractedModelName,modelH,opts,obj.ShowUI);
                if isempty(extractedModelFullPath)
                    msg=getString(message('Sldv:SubSysExtract:UnableGenExtractMdl'));
                    obj.setExtractError(msg,'Sldv:SubSysExtract:UnableGenExtractMdl');
                    obj.ModelH=[];
                    obj.Status=false;
                    return;
                end
            end
        end

        function renameExtractedBlock(obj,blockName)


            blockInExtractedModel=find_system(obj.ModelH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID','1');
            blockHInExtractedModel=get_param(blockInExtractedModel,'Handle');
            set_param(blockHInExtractedModel,'Name',blockName);
            try
                set_param(obj.ModelH,'DVExtractedSubsystem',blockName);
            catch
                add_param(obj.ModelH,'DVExtractedSubsystem',blockName);
            end
        end

        function setFixedStepSolver(obj)
            if obj.ExtractionMode==0
                modelOb=get_param(obj.ModelH,'Object');
                modelObAcs=modelOb.getActiveConfigSet;
                modelSolverType=modelObAcs.getProp('SolverType');

                if strcmp(modelSolverType,'Variable-step')
                    modelObAcs.setProp('SolverType','Fixed-step');
                    modelObAcs.setProp('Solver','FixedStepDiscrete');
                    modelObAcs.setProp('FixedStep','auto');
                end
            end
        end

        saveExtractedModel(obj);
    end
end

function extractedModelFullPath=deriveExtractedModelName(extractedModelName,modelH,opts,showUI)
    MakeOutputFilesUnique='off';
    try

        extractedModelFullPath=Sldv.utils.settingsFilename(extractedModelName,MakeOutputFilesUnique,...
        '$ModelExt$',modelH,showUI,true,opts);
    catch Mex %#ok<NASGU>
        extractedModelFullPath=[];
    end
end

function extractedModelName=ensureNoConflictingVar(modelHandle,extractedModelName)




    count=0;
    baseModelName=extractedModelName;
    maxIdLength=get_param(modelHandle,'MaxIdLength');


    while checkMdlNameinvalid()
        extension=num2str(count);
        totalLength=length(baseModelName)+length(extension);
        if totalLength>maxIdLength
            lastCharFromBase=maxIdLength-length(extension);
            baseModelName=baseModelName(1:lastCharFromBase);
        end
        extractedModelName=sprintf('%s%i',baseModelName,count);
        count=count+1;
    end

    function flag=checkMdlNameinvalid()

        if evalin('base',sprintf('exist(''%s'', ''var'')',extractedModelName))
            flag=1;
            return;
        end






        list=which(extractedModelName,'-all');
        len=length(list);

        if(len>1)
            flag=true;
            return;
        end




        if(len==1)&&~strcmp(extractedModelName,get_param(modelHandle,'name'))
            flag=1;
            return;
        end

        flag=0;
    end
end


