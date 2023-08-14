classdef(Abstract)Node<handle&matlab.mixin.Copyable&dynamicprops&matlab.mixin.Heterogeneous




    properties(Hidden)
        Name char
SourceObject
        Parent Simulink.typeeditor.app.Node
Children
        Path char
        InErrorOrWarning struct=struct('Mode',false,'Property','','State','','Message','')
        ErrorPropName char
    end

    properties(Access=protected)
DialogHandle
DialogTag
    end

    properties(Access=protected)
        mDynamicProps meta.DynamicProperty
    end

    methods
        function val=get.Name(this)
            val=this.getValueForName;
            if isempty(val)
                val=this.Name;
            end
        end
    end

    methods(Access=protected)

        function objCopy=copyElement(obj)
            objCopy=eval([class(obj),'.empty']);
        end
    end

    methods(Hidden)
        function this=Node(varargin)
        end

        function res=find(this,childName)%#ok<INUSD>
            res=eval([class(this.Children),'.empty']);
        end

        function resIdx=findIdx(this,childName)%#ok<INUSD>
            resIdx=[];
        end

        function delete(this)%#ok<INUSD>
        end

        function ch=getChildren(this,~)%#ok<INUSD>
            ch=[];
        end

        function num=getNumChildren(this)
            num=length(this.getChildren);
        end

        function names=getChildrenNames(this)
            ch=this.getChildren;
            names={};
            if~isempty(this.getChildren)
                names={ch.Name};
            end
        end

        function yesNo=isHierarchical(this)
            yesNo=~isempty(this.Children);
        end

        function yesNo=isValidProperty(this,propName)%#ok<INUSD>
            yesNo=true;
        end

        function propValue=getPropValue(this,propName)%#ok<INUSD>
            propValue='';
        end

        function setPropValue(this,propName,propValue)%#ok<INUSD>

        end

        function icon=getDisplayIcon(this)%#ok<MANU>
            icon=Simulink.typeeditor.utils.getBusEditorResourceFile('prevent_16.png');
        end

        function label=getDisplayLabel(this)%#ok<MANU>
            label='N/A';
        end

        function items=getContextMenuItems(this)%#ok<MANU>
            items=[];
        end

        function yesNo=isDragAllowed(this)%#ok<MANU>
            yesNo=false;
        end

        function yesNo=isDropAllowed(this)%#ok<MANU>
            yesNo=false;
        end

        function yesNo=isReadonlyProperty(this,propName)%#ok<INUSD>

            yesNo=false;
        end

        function yesNo=isEditableProperty(this,propName)%#ok<INUSD>

            yesNo=false;
        end

        function root=getRoot(this)
            root=this.Parent.getRoot;
        end

        function ed=getEditor(~)
            ed=Simulink.typeeditor.app.Editor.getInstance;
        end

        function reportErrorFromContext(this,varargin)
            ed=this.getEditor;
            activeComp=ed.getStudio.getActiveComponent;
            if isequal(ed.getDialogComp,activeComp)
                this.reportPIError(varargin{:});
            elseif isequal(ed.getListComp,activeComp)
                this.reportSSError(varargin{:});
            end
        end

        function reportPIError(this,varargin)
            ed=this.getEditor;
            propInsp=ed.getDialogComp;
            if isvalid(propInsp)&&~propInsp.isMinimized
                dlg=this.getDASDialogHandle;
                if~isempty(dlg)&&ishandle(dlg)
                    switch nargin
                    case 5
                        err=DAStudio.UI.Util.Error;
                        err.ID=varargin{1};
                        propName=varargin{3};
                        this.ErrorPropName=propName;
                        type=varargin{4};
                        assert(ismember(type,{'Error','Warning'}));
                        err.Tag=[type,'_',propName];
                        err.Type=type;
                        err.Message=varargin{2};
                        switch type
                        case 'Error'
                            err.HiliteColor=[255,0,0,255];
                        case 'Warning'
                            err.HiliteColor=[250,196,0,255];
                        end
                        dlg.setWidgetWithError(propName,err);
                        DA_ED=DAStudio.EventDispatcher;
                        DA_ED.broadcastEvent('PropertyUpdateRequestEvent',dlg,{propName,''});
                    case 2
                        propName=varargin{1};
                        dlg.clearWidgetWithError(propName);
                    case 1
                        if slfeature('TypeEditorStudio')>0
                            dlg.clearWidgetWithError(this.ErrorPropName);
                        end
                    otherwise
                        assert(false);
                    end
                end
            end
        end

        function reportSSError(this,varargin)
            if slfeature('TypeEditorStudio')>0
                ed=this.getEditor;
                if nargin>2
                    this.InErrorOrWarning.Mode=true;
                    this.InErrorOrWarning.Message=varargin{2};
                    if any(strcmp(varargin{3},{DAStudio.message('Simulink:busEditor:PropDataType'),...
                        DAStudio.message('Simulink:busEditor:PropDataTypeMode'),...
                        DAStudio.message('Simulink:busEditor:PropBaseType')}))
                        this.InErrorOrWarning.Property=DAStudio.message('Simulink:busEditor:PropType');
                    else
                        this.InErrorOrWarning.Property=varargin{3};
                    end
                    this.InErrorOrWarning.State=varargin{4};
                    assert(ismember(this.InErrorOrWarning.State,{'Error','Warning'}));
                    ed.setErroredRowsSS(this);
                else
                    this.resetSSErrorState;
                end
                ed.getListComp.update(this);
            end
        end

        function highlightReferencedTypes(this)






            if slfeature('TypeEditorStudio')>0
                typeToHighlightStrs=split(this.getPropValue('Type'),':');
                typeToHighlight=strtrim(typeToHighlightStrs{end});
                if this.doesVariableExistInWorkspace(typeToHighlight)
                    nodeToHighlight=this.getRoot.find(typeToHighlight);
                    assert(~isempty(nodeToHighlight));
                    nodeToHighlight.HighlightMode=true;
                    ed=this.getEditor;
                    lc=ed.getListComp;
                    lc.update(nodeToHighlight);
                    ed.setHighlightedRows(nodeToHighlight);
                end
            end
        end

        function resetSSErrorState(this)
            this.InErrorOrWarning.Mode=false;
            this.InErrorOrWarning.Message='';
            this.InErrorOrWarning.Property='';
            this.InErrorOrWarning.State='';
        end

        function doesExist=doesVariableExistInWorkspace(this,propValue)
            root=this.getRoot;
            doesExist=root.NodeDataAccessor.hasVariable(propValue);
        end
    end

    methods(Access=protected,Hidden)
        function val=getValueForName(this)%#ok<MANU>
            val='';
        end


        function h=getDASDialogHandle(this)


            if isempty(this.DialogHandle)||~ishandle(this.DialogHandle)
                dlg=DAStudio.ToolRoot.getOpenDialogs;
                for i=1:length(dlg)
                    if strcmp(dlg(i).dialogTag,this.DialogTag)
                        this.DialogHandle=dlg(i);
                        break;
                    end
                end
            end
            h=this.DialogHandle;
        end

        function yes=isInMultiselect(this)
            ed=this.getEditor();
            listSel=ed.getCurrentListNode;
            multiSelect=length(listSel)>1;
            isPresent=false;
            equalFn=@(item)strcmp(item.Name,this.Name)&&...
            strcmp(class(item),class(this));
            if multiSelect
                isPresent=any(arrayfun(@(sel)equalFn(sel),[listSel{:}]));
            end
            yes=multiSelect&&isPresent;
        end

        function widgetGroup=setImmediate(this,widgetGroup)
            if isfield(widgetGroup,'Items')
                for i=1:length(widgetGroup.Items)
                    if isfield(widgetGroup.Items{i},'Type')&&...
                        ~any(strcmp(widgetGroup.Items{i}.Type,{'panel','group','togglepanel','tab'}))
                        widgetGroup.Items{i}.Mode=true;
                        widgetGroup.Items{i}.Graphical=true;
                    else
                        widgetGroup.Items{i}=this.setImmediate(widgetGroup.Items{i});
                    end
                    if isfield(widgetGroup.Items{i},'Source')
                        widgetGroup.Items{i}=rmfield(widgetGroup.Items{i},'Source');
                    end
                end
            end
        end

        function widgetGroup=setDisabled(~,widgetGroup)
            if isfield(widgetGroup,'Items')
                for i=1:length(widgetGroup.Items)
                    widgetGroup.Items{i}.Enabled=false;
                end
            end
        end

        function outStr=escapeForSprintf(~,str)
            outStr=strrep(str,'\','\\');
            outStr=strrep(outStr,'''','''''');
            outStr=strrep(outStr,'%','%%');
        end

        function outStr=addQuoteIfNonNumericString(this,inStr,propName)



            if strcmpi(propName,DAStudio.message('Simulink:busEditor:PropDimensions'))||...
                strcmpi(propName,DAStudio.message('Simulink:busEditor:PropSampleTime'))||...
                strcmpi(propName,DAStudio.message('Simulink:busEditor:PropMin'))||...
                strcmpi(propName,DAStudio.message('Simulink:busEditor:PropMax'))||...
                strcmpi(propName,DAStudio.message('Simulink:busEditor:PropAlignment'))||...
                strcmpi(propName,DAStudio.message('Simulink:busEditor:PropIsAlias'))||...
                (strcmpi(propName,DAStudio.message('Simulink:busEditor:PropPreserveElementDimensions'))&&...
                (slfeature('NdIndexingBusUI')==1))
                outStr=inStr;
            else
                outStr=['''',this.escapeForSprintf(inStr),''''];
                outStr=['sprintf(',strrep(outStr,newline,'\n'),')'];
            end
        end
    end
end
