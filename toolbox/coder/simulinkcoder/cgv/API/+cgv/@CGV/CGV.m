


















classdef CGV<handle

    properties
        Name='';
        Description='';
    end

    properties(SetAccess=private)



        ModelName=[];


        SubModels={};



        PostLoadFilesList={};


        InputData={};

        UserAddedConfigSet=[];
        UserAddedConfigSetAttachedName={};

        UserDir=[];



        OutputDataName=[];
        ReturnWorkspaceOutputs=false;

        SaveFormat=[];
        GenerateReport='off';

        CheckInterface=true;
        ExecEnv=[];




        OutputDir=[];
        OutputData={};

        MetaData=[];


        RunHasBeenCalled=0;

    end

    properties(SetAccess=private,Hidden)


        CallbackFcn;



        NoInputData=false;
        ConfigModel=true;
        SimParams=[];
        OrigDir=[];
        ConfigSetName=[];
        ConfigSetNameOriginal={};


        ConfigSetLoadStatus={};


        HeaderReportFcn={};
        PreReportFcn={};
        PostReportFcn={};
        TrailerReportFcn={};
        PreExecFcn={};
        PostExecFcn={};






        Dependencies={};

        WorkDir=[];
        Overwrite='';

        Debug=0;
    end


    properties(Hidden)


        ReportData;


        UserData;
    end

    properties(GetAccess=private,Constant=true)
        ValidModes={'normal','sim','sil','pil'};
    end

    methods







        function this=CGV(model,varargin)
            if nargin<1
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end

            this.OrigDir=pwd;
            [pathstr,name,ext]=fileparts(model);


            if~isempty(pathstr)&&(pathstr(1)=='/'||pathstr(1)=='\')
                if length(pathstr)==1||isempty(name)
                    DAStudio.error('RTW:cgv:AvoidPrependedSlashes',model);
                end
            end
            if~isempty(ext)&&~(strcmp(ext,'.mdl')||strcmp(ext,'.slx'))
                DAStudio.error('RTW:cgv:ModelParamCanOnlyHaveMdlExtension',model);
            end
            model=fullfile(pathstr,name);
            if~exist([model,'.mdl'],'file')&&~exist([model,'.slx'],'file')
                DAStudio.error('RTW:cgv:CantFindModel',model);
            end

            this.ModelName=name;
            if~isempty(pathstr)
                cd(pathstr);
            end

            this.OutputDir=pwd;
            this.WorkDir=pwd;
            this.Overwrite='off';
            this.ExecEnv.Obj=[];
            this.UserDir=pwd;



            checkDirty(this,false);


            this.ExecEnv.Save=false;
            this.ExecEnv.ConfigArgs={};

            validParams={{'ComponentType',{'modelblock','topmodel'}},...
...
            {'Connectivity',[this.ValidModes,{'tasking','custom'}]},...
            {'SaveModel',{'on','off'}},...
            {'LogMode',{'SaveOutput','SignalLogging'}},...
            {'Processor',{'Arm','TriCore','C166','8051','M16C','DSP563xx'}},...
            {'debug',{'on'}},...
            {'CheckInterface',{'on','off'}},...
            {'ConfigModel',{'on','off'}},...
            };
            displayParams={{'ComponentType',{'modelblock','topmodel'}},...
            {'Connectivity',{'sim','normal','sil','pil'}},...
            };
            args=cgv.Config.checkArgs(2,'cgv.CGV',validParams,displayParams,varargin);

            unsupportedParameter={};
            parameterToConfig={};
            if isfield(args,'debug')
                this.Debug=1;
            end
            if isfield(args,'componenttype')
                componentType=lower(args.componenttype);
                this.ExecEnv.ConfigArgs{end+1}='componenttype';
                this.ExecEnv.ConfigArgs{end+1}=args.componenttype;
            else
                componentType='topmodel';
            end
            if isfield(args,'connectivity')
                if strcmpi(args.connectivity,'tasking')
                    index=i_find(this,'connectivity',varargin);
                    unsupportedParameter{end+1}=[varargin{index},'/',varargin{index+1}];
                elseif strcmpi(args.connectivity,'custom')
                    index=i_find(this,'connectivity',varargin);
                    unsupportedParameter{end+1}=[varargin{index},'/',varargin{index+1}];
                end
                connectivity=lower(args.connectivity);
                this.ExecEnv.ConfigArgs{end+1}='connectivity';
                this.ExecEnv.ConfigArgs{end+1}=args.connectivity;
            else
                connectivity='normal';
            end
            if isfield(args,'processor')
                index=i_find(this,'processor',varargin);
                parameterToConfig{end+1}=varargin{index};
            end

            if isfield(args,'logmode')
                index=i_find(this,'logmode',varargin);
                parameterToConfig{end+1}=varargin{index};
            end

            if isfield(args,'savemodel')
                index=i_find(this,'savemodel',varargin);
                parameterToConfig{end+1}=varargin{index};
            end

            if isfield(args,'checkinterface')
                index=i_find(this,'checkinterface',varargin);
                if strcmpi(args.checkinterface,'off')
                    DAStudio.warning('RTW:cgv:UnsupportedOffWarn',varargin{index});
                else
                    unsupportedParameter{end+1}=varargin{index};
                end
            end

            if isfield(args,'configmodel')
                index=i_find(this,'configmodel',varargin);
                if strcmpi(args.configmodel,'off');
                    DAStudio.warning('RTW:cgv:UnsupportedOffWarn',varargin{index});
                else
                    unsupportedParameter{end+1}=varargin{index};
                end
            end
            if~isempty(parameterToConfig)
                paramStr=parameterToConfig{1};
                if length(parameterToConfig)>1
                    paramStr=[paramStr,sprintf(', %s',parameterToConfig{2:end})];
                end
                DAStudio.error('RTW:cgv:ParameterToConfig',paramStr);
            end
            if~isempty(unsupportedParameter)
                paramStr=unsupportedParameter{1};
                if length(unsupportedParameter)>1
                    paramStr=[paramStr,sprintf(', %s',unsupportedParameter{2:end})];
                end
                DAStudio.error('RTW:cgv:UnsupportedParameter',paramStr);
            end

            addTarget(this,componentType,connectivity);


            loadStatus=verifyLoaded(this.ModelName);

            this.SaveFormat=get_param(this.ModelName,'SaveFormat');
            this.GenerateReport=get_param(this.ModelName,'GenerateReport');

            outportList=find_system(this.ModelName,'SearchDepth',1,'BlockType','Outport');

            if strcmp(loadStatus,'notloaded')
                close_system(this.ModelName);
            end


            if isempty(outportList)
                DAStudio.error('RTW:cgv:NoOutputs',this.ModelName);
            end

            cd(this.OrigDir);
        end

        function setMode(this,mode)
            if~ischar(mode)
                DAStudio.error('RTW:cgv:ParamToFcnMustBeString','setMode')
            end
            if~ismember(lower(mode),this.ValidModes)
                DAStudio.error('RTW:cgv:InvalidParam',mode)
            end
            this.deleteTargetObj();
            addTarget(this,this.ExecEnv.Obj.ComponentType,lower(mode));
        end

        function addHeaderReportFcn(this,callbackFcn)
            if nargin~=2
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            this.checkCallback(callbackFcn,1);
            this.HeaderReportFcn=callbackFcn;
        end
        function addPreExecReportFcn(this,callbackFcn)
            if nargin~=2
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            this.checkCallback(callbackFcn,2);
            this.PreReportFcn=callbackFcn;
        end
        function addPostExecReportFcn(this,callbackFcn)
            if nargin~=2
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            this.checkCallback(callbackFcn,2);
            this.PostReportFcn=callbackFcn;
        end
        function addTrailerReportFcn(this,callbackFcn)
            if nargin~=2
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            this.checkCallback(callbackFcn,1);
            this.TrailerReportFcn=callbackFcn;
        end
        function addPostExecFcn(this,callbackFcn)
            if nargin~=2
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            this.checkCallback(callbackFcn,2);
            this.PostExecFcn=callbackFcn;
        end
        function addPreExecFcn(this,callbackFcn)
            if nargin~=2
                DAStudio.error('RTW:cgv:InvalidNumberOfArgs');
            end
            this.checkCallback(callbackFcn,2);
            this.PreExecFcn=callbackFcn;
        end
    end

    methods(Hidden)
        function setSimParams(this,simParams)
            simParams.ReturnWorkspaceOutputs='on';
            this.SimParams=simParams;
        end

        addCallback(this,callback);
        setWorkingDir(this,dir,varargin);
        addDependencies(this,dependList);
    end

    methods(Access=private)

        function checkCallback(~,callbackFcn,expectedNumArgs)
            if~isa(callbackFcn,'function_handle')
                DAStudio.error('RTW:cgv:NotFunctionHandle');
            elseif nargin(callbackFcn)~=expectedNumArgs
                stk=dbstack;
                DAStudio.error('RTW:cgv:CallbackNeedsNParams',stk(2).name,expectedNumArgs,nargin(callbackFcn));
            end
        end

        function deleteTargetObj(this)
            if~isempty(this.ExecEnv)&&isa(this.ExecEnv.Obj,'cgvTarget.TargetBase')
                this.ExecEnv.Obj.delete;
            end
        end

        function delete(this)
            if~isempty(this.ModelName)
                model=this.ModelName;
                try

                    dirty=get_param(model,'dirty');
                    if strcmp(dirty,'on')
                        disp(DAStudio.message('RTW:cgv:ModelChangedNotClosing',model));
                        open_system(model);
                    end
                catch %#ok<CTCH>

                end
            end
            this.deleteTargetObj();
        end

        function index=i_find(~,param,cellarray)
            index=1;
            for i=1:length(cellarray)
                if strcmpi(param,cellarray{i})
                    index=i;
                    return;
                end
            end
        end
    end

    methods(Static,Hidden)
        list=getSavedSignals(dataSet);
        createToleranceFile(filename,varargin);
        [matchNames,matchFigures,mismatchNames,mismatchFigures]=compare(dataSet1,dataSet2,varargin);
        [names,figures]=plot(dataSet1,varargin);
        [TestResults,Pass,Fail,Error,reportFile]=runTests(varargin);
        list=dataSrcsList(sdie,dataRunID);
    end

end




