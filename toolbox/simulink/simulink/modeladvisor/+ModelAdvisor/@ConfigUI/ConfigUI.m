classdef(CaseInsensitiveProperties=true)ConfigUI<matlab.mixin.Heterogeneous&matlab.mixin.Copyable&matlab.mixin.internal.TreeNode













    properties(Dependent=true)
    end

    properties(SetAccess=public,Hidden=true)
    end

    properties(SetAccess=public)

        ID='';


        OriginalNodeID='';



        Protected=false;


        DisplayName='';


        DisplayLabelPrefix='';


        Description='';


        HelpMethod='';


        HelpArgs={};


        Selected=false;


        SelectedGUI='checked';


        InTriState=false;





        NeedToggleForTriState=false;


        Type='';


        Visible=true;


        Enable=true;




        Value='';


        Published=true;


        ShowCheckbox=true;


        LicenseName={};


        CSHParameters={};


        InLibrary=false;



        MAObj={};


        ByTaskMode=false;


        ParentObj={};


        ChildrenObj={};


        Index=0;


        MAC='';


        MACIndex=0;


        Severity='Optional';




        InputParameters={};



        InputParametersLayoutGrid=[];

        InputParametersCallback={};


        LastModifiedDate=0;


        SupportsEditTime=0;


        isBlockConstraintCheck=0;

    end

    methods(Static=true)
        newgui;
        cutgui;
        deletegui;
        moveup;
        movedown;
        copygui;
        pastegui;
        enablegui;
        disablegui;
        newfolder;
        closeExplorer;
        librarybrowser;
        output=stackoperation(method);
        opencsh;
        configFileIsValid=openLoadDlg;
        openRestoreDlg(varargin);
        openSaveDlg;
        openSaveAsDlg;
        obj=loadobj(B);
        [edittimeJSON,edittimeXML]=setEditTimeCheckingBehavior(filePath,varargin);
        this=createFromMANodeObj(nodeobj);
        nodeobj=convertTaskAdvisor(this);
    end

    methods
        function set.DisplayName(obj,value)
            obj.DisplayName=setProperty(obj,value);
        end
        function set.Selected(obj,value)
            obj.Selected=setProperty(obj,value);
        end
        function set.Enable(obj,value)
            obj.Enable=setProperty(obj,value);
        end
        function set.Value(obj,value)
            obj.Value=setProperty(obj,value);
        end
        function set.ParentObj(obj,value)
            obj.ParentObj=setProperty(obj,value);
        end



        function set.InputParameters(obj,value)
            obj.InputParameters=setProperty(obj,value);
        end
        function set.InputParametersLayoutGrid(obj,value)
            obj.InputParametersLayoutGrid=setProperty(obj,value);
        end

        function set.SelectedGUI(obj,value)
            obj.setSelectedGUI(value);
        end

        function value=get.SelectedGUI(obj)
            value=obj.getSelectedGUI;
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
        function val=isValidProperty(~,propName)
            if strcmp(propName,'Name')
                val=false;
            else
                val=true;
            end
        end


        function this=ConfigUI(varargin)
            if nargin>0&&isa(varargin{1},'ModelAdvisor.Node')
                nodeobj=varargin{1};
                this=ModelAdvisor.ConfigUI.createFromMANodeObj(nodeobj);
            end
        end

        dlgStruct=getDialogSchema(this,name);
        val=getDisplayIcon(this);
        val=getDisplayLabel(this);
        val=getChildren(this);
        val=getHierarchicalChildren(this);
        propname=getCheckableProperty(this);
        readonly=isReadonlyProperty(h,propname);
        cm=getContextMenu(this,~);
        val=isHierarchical(this);
        val=isHierarchyReadonly(this);
        dropok=canAcceptDrop(this,acceptNode,dropObjects);
        tf=acceptDrop(this,acceptNode,dropObjects);
        handleCheckEvent(this,tag,handle);

    end
end


function valueStored=setProperty(this,valueProposed)


    if isa(this.MAObj,'Simulink.ModelAdvisor')&&(this.InLibrary==false)
        this.MAObj.ConfigUIDirty=true;
    end
    valueStored=valueProposed;
end