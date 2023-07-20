classdef AbstractNode<handle







    methods(Abstract,Access=public)
        name=getCachedName();
        columnNames=getPIPropertyNames(this);
        isHier=isHierarchical(this);
        displayLabel=getDisplayLabel(this);
        icon=getDisplayIcon(this);
        children=getHierarchicalChildren(this);
        isValid=isValidProperty(this,columnName);
        isReadonly=isReadonlyProperty(this,columnName);
        dataType=getPropDataType(this,columnName);
        values=getPropAllowedValues(this,columnName);
        propVal=getPropValue(this,columnName);
        setPropValue(this,columnName,propVal);
        isValid=isValid(this);

        dlgStruct=getDialogSchema(this);
        dialogTag=getDialogTag(this);
        objType=getObjectType(this);
        nodeType=getNodeType(this);

        allowed=isDragAllowed(this);
        allowed=isDropAllowed(this);

        contextMenu=getContextMenuItems(this);
    end

    methods(Abstract,Access=protected)
        studio=getStudio(this);

        initializeMimeData(this);
    end

    properties(Dependent,Access=public)
        Name;
    end

    properties(Constant,Access=protected)
        MimeType='application/interfacedict-mimetype';
    end

    properties(Access=protected)
        MimeData=[];
    end

    methods
        function name=get.Name(this)
            if this.isValid()
                name=this.getPropValue('Name');
            else


                name=this.getCachedName();
            end
        end

        function set.Name(~,~)
            assert(false,'Cannot set name of node');
        end
    end

    methods(Access=protected)
        function reportPIError(this,widgetName,mException)
            dlg=this.getPIDialog();
            err=DAStudio.UI.Util.Error;
            err.ID=mException.identifier;
            err.Message=mException.message;
            err.Tag=['Error_',widgetName];
            err.Type='Error';
            err.HiliteColor=[255,0,0,255];
            dlg.setWidgetWithError(widgetName,err);
            DA_ED=DAStudio.EventDispatcher;
            DA_ED.broadcastEvent('PropertyUpdateRequestEvent',dlg,{widgetName,''});
        end

        function clearPIError(this,widgetName)
            dlg=this.getPIDialog();
            dlg.clearWidgetWithError(widgetName);
        end
    end

    methods(Access=private)
        function dlg=getPIDialog(this)
            dlg=[];
            thisDialogTag=this.getDialogTag();
            openDialogs=DAStudio.ToolRoot.getOpenDialogs;
            for i=1:length(openDialogs)
                if strcmp(openDialogs(i).dialogTag,thisDialogTag)
                    dlg=openDialogs(i);
                    break;
                end
            end
        end
    end

    methods(Access=public)
        function refreshDialog(this)
            if~this.isValid()

                return;
            end
            dlg=this.getPIDialog();
            if~isempty(dlg)
                dlg.refresh();
            end
        end


        function mimeType=getMimeType(this)
            mimeType=this.MimeType;
        end

        function mimeData=getMimeData(this)
            if isempty(this.MimeData)
                this.initializeMimeData();
            end
            mimeData=this.MimeData;
        end
    end


    methods(Hidden)

        function out=getPropertySchema(this)
            out=this;
        end

        function s=getObjectName(this)
            s=this.Name;
        end

        function tf=supportTabView(~)
            tf=false;
        end

        function mode=rootNodeViewMode(~,rootProp)
            mode='Undefined';
            if isempty(rootProp)||strcmp(rootProp,'InterfaceDictionary:Properties')
                mode='SlimDialogView';
            end
        end

        function subprops=subProperties(~,prop)
            subprops={};
            if isempty(prop)
                subprops{1}='InterfaceDictionary:Properties';
            end
        end

        function showPropertyHelp(~,prop)
            if isempty(prop)
                helpview(fullfile(docroot,'mapfiles','simulink.map'),'autosar_shared_dictionary');
            end
        end

        function label=propertyDisplayLabel(~,prop)
            label=prop;
            if strcmp(prop,'InterfaceDictionary:Properties')
                label=getString(message('interface_dictionary:common:propInspectorTitle'));
            end
        end
    end
end


