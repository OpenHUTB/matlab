classdef CosimWizardDlg<handle




    properties(SetObservable,GetObservable)

        UserData=[];

        Status{matlab.internal.validation.mustBeASCIICharRowVector(Status,'Status')}='';

        StepHandles=[];

        StepID=0;

        NextStepID=0;

        WidgetStackItems=[];

        EnableButtons=false;

        Simulator{matlab.internal.validation.mustBeASCIICharRowVector(Simulator,'Simulator')}='ModelSim';

        FileTable=[];

        CompileCmd{matlab.internal.validation.mustBeASCIICharRowVector(CompileCmd,'CompileCmd')}='';

        TopLevelName{matlab.internal.validation.mustBeASCIICharRowVector(TopLevelName,'TopLevelName')}='';

        LoadOptions{matlab.internal.validation.mustBeASCIICharRowVector(LoadOptions,'LoadOptions')}='';

        ElabOptions{matlab.internal.validation.mustBeASCIICharRowVector(ElabOptions,'ElabOptions')}='';

        HdlTimeUnit{matlab.internal.validation.mustBeASCIICharRowVector(HdlTimeUnit,'HdlTimeUnit')}='ns';

        TimeScaleOpt(1,1)logical=true;

        TimingScaleFactor{matlab.internal.validation.mustBeASCIICharRowVector(TimingScaleFactor,'TimingScaleFactor')}='';

        TimingMode{matlab.internal.validation.mustBeASCIICharRowVector(TimingMode,'TimingMode')}='s';

        SampleTimeOpt{matlab.internal.validation.mustBeASCIICharRowVector(SampleTimeOpt,'SampleTimeOpt')}='';

        TriggerMode(1,1)double{mustBeReal}=0;

        CallBackFcnName{matlab.internal.validation.mustBeASCIICharRowVector(CallBackFcnName,'CallBackFcnName')}='';

        ErrMsg='';

        LastErrorID=[];

        workflowOverride=[];

        workflowOverrideTargetSystem='untitled';
    end


    methods
        function this=CosimWizardDlg(varargin)






            if nargin>0
                matFileName=varargin{1};
                if~isempty(matFileName)
                    r=load(matFileName);
                    this.UserData=r.cosimWizardInfo;
                    this.Simulator=this.UserData.Simulator;

                else
                    this.UserData=CosimWizardPkg.CosimWizardDataMQ;
                end
                if nargin==3
                    this.workflowOverride=varargin{2};
                    if~any(strcmp(this.UserData.WorkflowOptions,this.workflowOverride))
                        error(message('HDLLink:CosimWizard:InvalidWorkflow'));
                    end
                    this.UserData.Workflow=this.workflowOverride;
                    this.workflowOverrideTargetSystem=varargin{3};
                end

                if nargin==4
                    workflow=varargin{2};

                    hdlsim=varargin{4};
                    validatestring(hdlsim,hdlv.vc.stringValues('HDLSimulator'));
                    switch hdlsim
                    case 'ModelSim',this.UserData=CosimWizardPkg.CosimWizardDataMQ;
                    case 'Xcelium',this.UserData=CosimWizardPkg.CosimWizardDataIN;
                    case 'Vivado Simulator',this.UserData=CosimWizardPkg.CosimWizardDataVS;
                    end
                    this.UserData.Workflow=workflow;
                    this.Simulator=hdlsim;
                end
            else
                this.UserData=CosimWizardPkg.CosimWizardDataMQ;
            end



            this.FileTable=cell(0,2);
            this.EnableButtons=true;
            this.TimeScaleOpt=true;
            this.TimingScaleFactor='1';
            this.TimingMode='s';
            this.CallBackFcnName='callback_fcn';
            this.SampleTimeOpt='10';


            this.StepHandles=cell(1,12);
            this.StepID=1;
            this.NextStepID=1;

            this.StepHandles{1}=CosimWizardPkg.CosimType(this);
            this.StepHandles{2}=CosimWizardPkg.FileSelection(this);
            this.StepHandles{3}=CosimWizardPkg.CompileOption(this);
            this.StepHandles{4}=CosimWizardPkg.ModuleSelection(this);
            this.StepHandles{5}=CosimWizardPkg.PortList(this);
            this.StepHandles{6}=CosimWizardPkg.OutPorts(this);
            this.StepHandles{7}=CosimWizardPkg.ClockReset(this);
            this.StepHandles{8}=CosimWizardPkg.PassReset(this);
            this.StepHandles{9}=CosimWizardPkg.BlockGeneration(this);
            this.StepHandles{10}=CosimWizardPkg.CallbackFunc(this);
            this.StepHandles{11}=CosimWizardPkg.ScriptGeneration(this);
            this.StepHandles{12}=CosimWizardPkg.ObjGeneration(this);

            this.WidgetStackItems=cell(1,12);
            for m=1:12
                this.WidgetStackItems{m}=getWidgetGroup(this.StepHandles{m});
            end

        end

    end

    methods
        onMoveFileDown(this,dialog)
        onMoveFileUp(this,dialog)
    end


    methods(Hidden)
        clearStatusMessage(this,dlg)
        displayErrorMessage(this,dialog,errmsg)
        displayStatusMessage(this,dialog,errmsg)
        dlgStruct=getDialogSchema(this,~)
        h=getStepHandle(this)
        onAddCb(this,dlg)
        onBack(this,dlg)
        onBrowseComp(this,dlg)
        onBrowseHdlFile(this,dialog,filenames,pathname)
        onBrowseHdlPath(this,dialog)
        onBrowseTrigger(this,dlg)
        onCancel(this,~)
        onClearCbFields(this,dlg)
        onHelp(this,~)
        onInherit(this,dialog)
        onNext(this,dlg)
        onRemoveCb(this,dlg)
        onRemoveHdlFile(this,dlg)
        onResetCompileCmd(this,dialog)
        onResetLoadOpt(this,dialog)
        onRetrieveCb(this,dlg)
        onSimulatorChange(this,dlg,val,tag)
        onVivadoElabOptionChange(this,dlg,val,tag)
        onUpdatePlot(this,dlg)
    end

    methods
        function set.CallBackFcnName(obj,value)
            obj.CallBackFcnName=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.SampleTimeOpt(obj,value)
            obj.SampleTimeOpt=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.TimingMode(obj,value)
            obj.TimingMode=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.TimingScaleFactor(obj,value)
            obj.TimingScaleFactor=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.HdlTimeUnit(obj,value)
            obj.HdlTimeUnit=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.ElabOptions(obj,value)
            obj.ElabOptions=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.LoadOptions(obj,value)
            obj.LoadOptions=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.TopLevelName(obj,value)
            obj.TopLevelName=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.CompileCmd(obj,value)
            obj.CompileCmd=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.Simulator(obj,value)
            obj.Simulator=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.Status(obj,value)
            obj.Status=matlab.internal.validation.makeCharRowVector(value);
        end
    end
end





