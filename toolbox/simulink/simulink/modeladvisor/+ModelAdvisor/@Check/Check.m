



classdef(CaseInsensitiveProperties=true)Check<matlab.mixin.Heterogeneous&matlab.mixin.Copyable

    properties(Dependent=true,SetAccess=public,Hidden=true)
        TitleID;
        TitleTips;
        PreCallbackHandle;
        PostCallbackHandle;
        Value;
        PushToModelExplorer;
        PushToModelExplorerProperties;
        SelectedListViewParamIndex;
        ListViewCloseCallback;
        ListViewActionCallback;
        ListViewVisible;
        ListViewParameters;
    end

    properties(SetAccess=public,Hidden=true)
        SelectedByTask=false;
        Published=false;
        RunComplete=true;
        FoundObjects={};

        Version='';
        Type='Standard';
        ResultInHTML='';
        ResultData={};
        IsCustomCheck=true;
        CallbackFcnPath='';

        Selected=false;
        Index=0;
        TitleIsDuplicate=false;
        CSHParameters={};
        ProjectResultData={};
        ExclusionIndex=[];



        SupportHighlighting=true;
        SupportsEditTime=false;
        SupportsCppCodeReuse=false;
        TaskID="";

        EmitInvisibleInputParametersToReport=false;


        loadOutofdateInputParametersCallback=[];

        status=ModelAdvisor.CheckStatus.NotRun;
    end


    methods(Hidden=true)
        function[checkID,className]=getEdittimeClassInfo(obj)
            checkID=obj.ID;
            className=obj.CallbackHandle;
        end
    end


    properties(SetAccess=private)

        ResultDetails=[];
        statusBeforeJustification=ModelAdvisor.CheckStatus.NotRun;
    end

    properties(SetAccess=private,Hidden=true)
        ReportStyle='ModelAdvisor.Report.StandardStyle';
        SupportedReportStyles=ModelAdvisor.Report.CheckStyleFactory.getSupportedStyles();




        CacheResultInHTMLForNewCheckStyle='';
    end

    properties(Access=private,Hidden=true)
        isBlockConstraintCheck=false;
    end

    methods(Hidden=true)


        function bool=getIsBlockConstraintCheck(obj)
            bool=obj.isBlockConstraintCheck;
        end

        function setIsBlockConstraintCheck(obj,val)
            obj.isBlockConstraintCheck=val;
        end

        function setReportStyle(obj,val)
            obj.ReportStyle=val;
            if~ismember(val,obj.SupportedReportStyles)
                obj.SupportedReportStyles=[val,obj.SupportedReportStyles];
            end
        end

        function setSupportedReportStyles(obj,val)
            obj.SupportedReportStyles=val;
        end

        function setCacheResultInHTMLForNewCheckStyle(obj,val)
            obj.CacheResultInHTMLForNewCheckStyle=val;
        end

        function status=calculateCheckStatus(obj)
            status=ModelAdvisor.CheckStatus.NotRun;
            arrayViolationType=ModelAdvisor.CheckStatus.empty;
            for i=1:length(obj.ResultDetails)
                if isa(obj.ResultDetails(i),'ModelAdvisor.ResultDetail')
                    arrayViolationType(end+1)=obj.ResultDetails(i).getViolationStatus();
                end
            end
            if~isempty(arrayViolationType)
                obj.status=ModelAdvisor.CheckStatusUtil.getParentStatus(arrayViolationType);



                if obj.status==ModelAdvisor.CheckStatus.Informational
                    obj.status=ModelAdvisor.CheckStatus.Passed;
                end

                status=obj.status;
            end
        end

        function justify(obj,status)
            if status
                obj.statusBeforeJustification=obj.status;
                obj.status=ModelAdvisor.CheckStatus.Justified;
            else
                obj.status=obj.statusBeforeJustification;
                obj.statusBeforeJustification=ModelAdvisor.CheckStatus.NotRun;
            end
        end

    end

    properties(SetAccess=public)
        ID='';
        Title='';
        Description='';


        Visible=true;
        Enable=true;
        DefaultSelection=true;
        Group='';

        Result={};

        LicenseName={};
        HasANDLicenseComposition=true;






        InputParametersLayoutGrid=[];

        InputParametersCallback=[];
        EmitInputParametersToReport=true;
        SupportLibrary=false;
        SupportExclusion=false;
        Success=false;
        ErrorSeverity=0;
        DefaultErrorSeverity=0;
    end

    properties(Dependent=true,SetAccess=public)
        CallbackHandle;
    end
    properties(SetAccess=public)
        CallbackContext='None';
        CallbackStyle='StyleOne';
    end

    properties(NonCopyable)
        Action={};
        Undo={};



        Callback=[];
        ListView=[];
        InputParameters={};
    end

    methods(Hidden=true)

        function CopyResults(obj,origObj)
            fields={'ResultInHTML','ResultData','ProjectResultData','Result','Success','ErrorSeverity'};
            for i=1:length(fields)
                obj.(fields{i})=origObj.(fields{i});
            end
        end

        function setLegacyCheckStatus(obj)
            if(obj.status~=ModelAdvisor.CheckStatus.NotRun)
                return;
            end
            if(obj.Success)
                obj.status=ModelAdvisor.CheckStatus.Passed;
            else
                if(obj.ErrorSeverity>0)
                    obj.status=ModelAdvisor.CheckStatus.Failed;
                else


                    if strcmp(obj.CallbackStyle,'DetailStyle')&&...
                        ~isempty(obj.ResultDetails)
                        calculateCheckStatus(obj);
                        return;
                    end
                    obj.status=ModelAdvisor.CheckStatus.Warning;
                end
            end
        end

        function setCheckStatusFromString(this,charStatus)
            this.status=ModelAdvisor.CheckStatus.NotRun;
            if strncmpi(charStatus,'Warning',numel(charStatus))
                this.status=ModelAdvisor.CheckStatus.Warning;
            elseif strncmpi(charStatus,'Passed',numel(charStatus))
                this.status=ModelAdvisor.CheckStatus.Passed;
            elseif strncmpi(charStatus,'Failed',numel(charStatus))
                this.status=ModelAdvisor.CheckStatus.Failed;
            elseif strncmpi(charStatus,'Informational',numel(charStatus))
                this.status=ModelAdvisor.CheckStatus.Informational;
            end
        end
    end


    methods(Access=protected)

        function output=copyElement(this)
            output=copyElement@matlab.mixin.Copyable(this);

            if~isempty(this.Action)
                output.Action=copy(this.Action);
            end
            if~isempty(this.Undo)
                output.Undo=copy(this.Undo);
            end
            if~isempty(this.Callback)
                output.Callback=copy(this.Callback);
            end
            if~isempty(this.ListView)
                output.ListView=copy(this.ListView);
            end
            for m=1:numel(this.InputParameters)
                output.InputParameters{m}=copy(this.InputParameters{m});
            end
        end
    end

    methods

        function success=setHelp(this,varargin)
            success=ModelAdvisor.internal.setCustomHelp(this,varargin{:});
        end


        function CheckObj=Check(input)
            CheckObj.Callback=Advisor.Callback;
            CheckObj.ListView=ModelAdvisor.ListView;


            checkConstructor(CheckObj,convertStringsToChars(input));
        end


        function set.CallbackHandle(obj,value)
            obj.Callback.CallbackHandle=value;
            if ischar(value)

                obj.SupportsEditTime=true;
                obj.CallbackStyle='DetailStyle';
                if Advisor.Utils.edittimeCheckDefinedFixCallback(value,obj.ID)
                    myAction=ModelAdvisor.Action;
                    myAction.setCallbackFcn(@Advisor.Utils.defaultActionCBforEdittimeCheck);
                    myAction.Name=DAStudio.message('Simulink:tools:MAModifyAll');
                    myAction.Description='Click the button to fix the issues';
                    obj.setAction(myAction);
                end
            end
        end

        function set.CallbackContext(obj,value)
            value=Advisor.str2enum(value,'Advisor.ModelAdvisorCBContextEnum');
            if slfeature('UpdateDiagramForCodegen')<1&&strcmp('PostCompileForCodegen',value)
                [~,enum_str_values]=enumeration('Advisor.ModelAdvisorCBContextEnum');
                enum_str_values=setdiff(enum_str_values,value,'stable');
                cell2table(enum_str_values)
                DAStudio.error('MATLAB:class:InvalidEnumValue',value);
            end
            obj.CallbackContext=value;
        end

        function set.CallbackStyle(obj,value)
            value=Advisor.str2enum(value,'Advisor.ModelAdvisorCBStyleEnum');
            obj.CallbackStyle=value;
        end









        function set.PreCallbackHandle(obj,value)
            obj.Callback.PreCallbackHandle=value;
        end

        function set.PostCallbackHandle(obj,value)
            obj.Callback.PostCallbackHandle=value;
        end

        function value=get.CallbackHandle(obj)
            value=obj.Callback.CallbackHandle;
        end









        function value=get.PreCallbackHandle(obj)
            value=obj.Callback.PreCallbackHandle;
        end

        function value=get.PostCallbackHandle(obj)
            value=obj.Callback.PostCallbackHandle;
        end


        function setResultDetails(obj,value)
            if isa(value,'ModelAdvisor.ResultDetail')||isempty(value)
                obj.ResultDetails=value;
            else
                DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor.ResultDetail');
            end
        end



        function set.PushToModelExplorer(obj,value)
            obj.ListView.PushToModelExplorer=value;
        end

        function value=get.PushToModelExplorer(obj)
            value=obj.ListView.PushToModelExplorer;
        end

        function set.PushToModelExplorerProperties(obj,value)
            obj.ListView.PushToModelExplorerProperties=value;
        end

        function value=get.PushToModelExplorerProperties(obj)
            value=obj.ListView.PushToModelExplorerProperties;
        end

        function value=get.ListViewParameters(this)
            value=getListViewParameters(this);
        end

        function set.ListViewParameters(this,value)
            setListViewParameters(this,value);
        end

        function value=getListViewParameters(this)
            value=this.ListView.Parameters;
        end

        function setListViewParameters(this,inputParamArray)
            this.ListView.Parameters=inputParamArray;
        end

        function value=get.SelectedListViewParamIndex(obj)
            value=obj.ListView.SelectedParamIndex;
        end

        function set.SelectedListViewParamIndex(obj,value)
            obj.ListView.SelectedParamIndex=value;
        end


        function value=get.ListViewActionCallback(obj)
            value=obj.ListView.ActionCallback;
        end

        function set.ListViewActionCallback(obj,value)
            obj.ListView.ActionCallback=value;
        end

        function value=get.ListViewVisible(obj)
            value=obj.ListView.Visible;
        end

        function set.ListViewVisible(obj,value)
            obj.ListView.Visible=value;
        end

        function value=get.ListViewCloseCallback(obj)
            value=obj.ListView.CloseCallback;
        end

        function set.ListViewCloseCallback(obj,value)
            obj.ListView.CloseCallback=value;
        end



        function set.Type(obj,value)
            value=Advisor.str2enum(value,'Advisor.ModelAdvisorCheckTypeEnum');
            obj.Type=value;
        end

        function value=get.TitleID(obj)
            value=obj.ID;
        end

        function set.TitleID(obj,value)
            obj.ID=value;
        end

        function value=get.TitleTips(obj)
            value=obj.Description;
        end

        function set.TitleTips(obj,value)
            obj.Description=value;
        end

        function value=get.Value(obj)
            value=obj.DefaultSelection;
        end

        function set.Value(obj,value)
            obj.DefaultSelection=value;
        end

        function ID=getID(obj)
            ID=obj.ID;
        end

        function value=getInputParameters(this)
            value=this.InputParameters;
        end

        function value=getLicense(this)
            value=this.LicenseName;
        end

        function setLicense(this,licenseName)
            if iscell(licenseName)&&isempty(licenseName(cellfun(@(x)~ischar(x),licenseName)))
                this.LicenseName=licenseName;
            else
                DAStudio.error('Simulink:tools:MAInvalidParam','cell array of string');
            end
        end

        function setInputParametersLayoutGrid(this,layoutGrid)
            if isnumeric(layoutGrid)&&length(layoutGrid)==2&&layoutGrid(1)>0&&layoutGrid(2)>0
                this.InputParametersLayoutGrid=layoutGrid;
            elseif isempty(layoutGrid)
                this.InputParametersLayoutGrid=[length(this.InputParameters),1];
            else
                DAStudio.error('Simulink:tools:MAInvalidParam','integer');
            end
        end

        function setInputParametersCallbackFcn(this,functionHandle)
            if isa(functionHandle,'function_handle')
                this.InputParametersCallback=functionHandle;
            else
                DAStudio.error('Simulink:tools:MAInvalidParam','function_handle');
            end
        end

        function setCallbackFcn(this,CallbackFunctionHandle,CallbackFunctionContext,CallbackFunctionStyle)
            this.CallbackHandle=CallbackFunctionHandle;
            this.CallbackContext=CallbackFunctionContext;
            this.CallbackStyle=CallbackFunctionStyle;
        end

        function bool=setStatus(this,status)
            bool=false;
            if ischar(status)
                p=inputParser;
                addRequired(p,'status',@(x)any(validatestring(x,{'Passed',...
                'Failed','Error','Warning','Informational'})))
                parse(p,status);
                bool=true;
                this.setCheckStatusFromString(status);
            elseif strcmp(class(status),'ModelAdvisor.CheckStatus')
                this.status=status;
                bool=true;
            end
        end

        function strStatus=getStatus(this)
            strStatus=char(this.status);
        end

    end

    methods(Hidden=true)
        function setReportCallbackFcn(this,CallbackFunctionHandle)
            this.Callback.ReportCallbackHandle=CallbackFunctionHandle;
        end
    end

    methods(Static=true)







    end
end


function checkConstructor(this,input)
    if ischar(input)
        this.ID=input;
    elseif isa(input,'Simulink.MdlAdvisorCheck')

        this.ID=input.TitleID;

        this.Title=input.Title;
        this.TitleTips=input.TitleTips;



        if input.TitleInRAWFormat
            MSLDiagnostic('Simulink:tools:MAPropertyNolongerSupport','TitleInRAWFormat').reportAsWarning;
        end
        this.CallbackHandle=input.CallbackHandle;
        this.CallbackContext=input.CallbackContext;
        this.CallbackStyle=input.CallbackStyle;


        this.Published=input.VisibleInProductList;
        this.Visible=input.Visible;
        this.Enable=input.Enable;
        this.Value=input.Value;
        this.Group=input.Group;

        this.Result=input.Result;

        this.ResultInHTML=input.ResultInHTML;
        this.ResultData=input.ResultData;

        this.LicenseName=input.LicenseName;
        this.HasANDLicenseComposition=input.HasANDLicenseComposition;

        this.SupportExclusion=input.SupportExclusion;
        this.SupportLibrary=input.SupportLibrary;






        inputParam=input.InputParameters;
        if~isempty(inputParam)
            inputParamObjArray={};
            for k=1:length(inputParam)
                inputParamObj=ModelAdvisor.InputParameter;
                if~isfield(inputParam{k},'ToolTip')
                    inputParamObj.Description='';
                else
                    inputParamObj.Description=inputParam{k}.ToolTip;
                end
                if~isfield(inputParam{k},'RowSpan')
                    inputParamObj.setRowSpan([k,k]);
                else
                    inputParamObj.setRowSpan(inputParam{k}.RowSpan);
                end
                if~isfield(inputParam{k},'ColSpan')
                    inputParamObj.setColSpan([1,1]);
                else
                    inputParamObj.setColSpan(inputParam{k}.ColSpan);
                end
                if~isfield(inputParam{k},'Name')
                    inputParamObj.Name='';
                else
                    inputParamObj.Name=inputParam{k}.Name;
                end
                if~isfield(inputParam{k},'Type')
                    inputParamObj.Type='String';
                else
                    inputParamObj.Type=inputParam{k}.Type;
                end
                if~isfield(inputParam{k},'Enable')

                else
                    inputParamObj.Enable=inputParam{k}.Enable;
                end
                if~isfield(inputParam{k},'Visible')

                else
                    inputParamObj.Visible=inputParam{k}.Visible;
                end
                if~isfield(inputParam{k},'Entries')
                    inputParamObj.Entries={};
                    if strcmp(inputParamObj.Type,'Enum')
                        DAStudio.error('Simulink:tools:MAMissEntriesForEnum',input.CallbackFcnPath);
                    end
                else
                    inputParamObj.Entries=inputParam{k}.Entries;
                end
                if~isfield(inputParam{k},'Value')
                    switch inputParamObj.Type
                    case 'String'
                        inputParamObj.Value='';
                    case{'Enum','ComboBox'}
                        inputParamObj.Value=inputParam{k}.Entries{1};
                    case 'Bool'
                        inputParamObj.Value=false;
                    end
                else
                    inputParamObj.Value=inputParam{k}.Value;
                end
                inputParamObjArray{end+1}=inputParamObj;%#ok<AGROW>
            end
            this.setInputParameters(inputParamObjArray);
            this.setInputParametersLayoutGrid(input.InputParametersLayoutGrid);
        end


        if~isempty(input.ActionCallbackHandle)
            this.Action=ModelAdvisor.Action;
            this.Action.CallbackHandle=input.ActionCallbackHandle;
            this.Action.Enable=input.ActionEnable;
            this.Action.Success=input.ActionSuccess;
            this.Action.Name=input.ActionButtonName;
            this.Action.Description=input.ActionDescription;
            this.Action.ResultInHTML=input.ActionResultInHTML;
        end

        this.CallbackFcnPath=input.CallbackFcnPath;
        this.Selected=input.Selected;

        this.TitleIsDuplicate=input.TitleIsDuplicate;

        this.Index=input.Index;
        this.ListView.Parameters=input.ListViewParameters;
        this.ListView.SelectedParamIndex=input.SelectedListViewParamIndex;
        this.ListView.ActionCallback=input.ListViewActionCallback;
        this.ListView.CloseCallback=input.ListViewCloseCallback;
        this.ListView.Visible=input.ListViewVisible;


        if input.PushToModelExplorer
            this.PushToModelExplorer=input.PushToModelExplorer;
            this.PushToModelExplorerProperties=input.PushToModelExplorerProperties;
            this.ListViewVisible=true;
        end

        this.Success=input.Success;
        this.ErrorSeverity=input.ErrorSeverity;
        this.CSHParameters=input.CSHParameters;
    else
        DAStudio.error('Simulink:tools:MAInvalidParam','string')
    end
end


