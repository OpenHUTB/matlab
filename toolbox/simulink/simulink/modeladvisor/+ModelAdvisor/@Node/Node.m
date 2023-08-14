classdef(CaseInsensitiveProperties=true)Node<matlab.mixin.Heterogeneous&matlab.mixin.Copyable&matlab.mixin.internal.TreeNode
    properties(Dependent=true,SetAccess=public,Hidden=true)




        TitleID='';
    end

    properties(Dependent=true,SetAccess=public)

    end

    properties(Dependent=true)

    end

    properties(SetAccess=public,Hidden=true)
        InternalState='';
        ByTaskMode=false;
        InputParameters={};
        OverwriteHTML=true;


        HelpMethod='';
        HelpArgs={};
        CSHParameters={};

        CustomObject={};

        SelectedGUI='checked';

        InTriState=false;




        NeedToggleForTriState=false;
        Published=false;


        Hide=false;
        State=ModelAdvisor.CheckStatus.NotRun;

        Failed=false;



        StateIcon='';
        ShowCheckbox=true;
        ShowCheckboxInProcedure=false;
        Version='';
        LicenseName={};
        ReportName='';
        CustomDialogSchema=[];


        EnableReset=false;
        CallbackFcnPath='';
        ParentObj={};
        ParentIndex=[];
        Index=0;
        TitleIsDuplicate=false;
        RunTime=0;
    end

    properties(SetAccess=public)
        ID='';
        DisplayName='';
        Description='';
        Selected=false;
        Visible=true;
        Enable=true;



        Value='';
        MAObj={};
    end

    methods(Static=true)
        varargout=select;
        varargout=deselect;
        opencsh;
        toggleSourcetab;
        toggleExclusiontab;
        toggleTreeview(toggleNode);
        toggleCheckResultOverlay(mode);
        closeExplorer(this);
        runtofailure;
        runtohere;
        continuerun;
        resetall;
        resetgui;
        run;
    end

    methods
        dlgStruct=getDialogSchema(this,name);
        cm=getContextMenu(this,~);
        runTaskAdvisor(this);
        propname=getCheckableProperty(~);
        handleCheckEvent(this,tag,handle);

        function obj=Node
            mlock;
        end

        function success=setHelp(this,varargin)
            success=ModelAdvisor.internal.setCustomHelp(this,varargin{:});
        end

        function set.SelectedGUI(obj,value)
            obj.setSelectedGUI(value);
        end

        function value=get.SelectedGUI(obj)
            value=obj.getSelectedGUI;
        end





        function val=isValidProperty(~,propName)
            if strcmp(propName,'Name')
                val=false;
            else
                val=true;
            end
        end

        function readonly=isReadonlyProperty(h,~)
            if h.Enable==true
                readonly=false;
            else
                readonly=true;
            end
        end










        function val=getPropDataType(~,propName)
            val='string';
            switch(propName)


            case{'SelectedGUI'}
                val='enum';
            end
        end

        function setPropValue(this,propName,propvalue)
            this.(propName)=propvalue;
            if strcmp(propName,'SelectedGUI')
                ed=DAStudio.EventDispatcher;
                ed.broadcastEvent('PropertyChangedEvent',this);
            end
        end

        function val=getPropValue(this,propName)
            val='';




            if strcmp(propName,'SelectedGUI')
                val=this.(propName);
            end
        end

        function set.TitleID(obj,value)
            obj.ID=value;
        end

        function value=get.TitleID(obj)
            value=obj.ID;
        end

        function p=getParent(obj)
            p=obj.ParentObj;
        end
    end

    methods(Hidden=true)
        success=launchCustomHelp(this);
    end
end