



classdef BindingTableDialog<handle
    properties
        bindModeSourceDataObj;
    end
    methods
        function this=BindingTableDialog(bindModeSourceDataObj)
            this.bindModeSourceDataObj=bindModeSourceDataObj;
        end

        function schema=getDialogSchema(this)

            htmlPath='toolbox/simulink/ui/bind_mode/core/web/bind_mode/index.html';
            url=[htmlPath...
            ,'?modelName=',this.bindModeSourceDataObj.modelName...
            ,'&clientName=',this.bindModeSourceDataObj.clientName.char...
            ,'&allowMultipleConnections=',num2str(this.bindModeSourceDataObj.allowMultipleConnections)...
            ,'&disableSorting=',num2str(this.bindModeSourceDataObj.disableSorting)...
            ,'&ellipsisPosition=',this.bindModeSourceDataObj.ellipsisPosition...
            ,'&updateDiagramLabel=',this.bindModeSourceDataObj.updateDiagramLabel...
            ,'&requiresInputField=',num2str(this.bindModeSourceDataObj.requiresInputField)];
            if this.bindModeSourceDataObj.requiresInputField
                url=[url...
                ,'&inputLabel=',this.bindModeSourceDataObj.inputLabel...
                ,'&inputPlaceholder=',this.bindModeSourceDataObj.inputPlaceholder];
            end
            url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
            webbrowser.Type='webbrowser';
            webbrowser.Tag='DDGWebBrowser';
            webbrowser.Url=url;
            webbrowser.HTML='';
            webbrowser.WebKit=true;
            webbrowser.WebKitToolBar={};
            webbrowser.HomeURL='';
            webbrowser.PageNotFoundUrl='';
            webbrowser.EnableInspectorInContextMenu=false;
            webbrowser.EnableInspectorOnLoad=false;
            webbrowser.ClearCache=false;
            webbrowser.Debug=false;
            webbrowser.EnableJsOnClipboard=false;
            webbrowser.EnableZoom=false;

            schema.DialogTitle='';
            schema.DialogTag='BindModeDialog';
            schema.Items={webbrowser};
            schema.StandaloneButtonSet={''};
            schema.EmbeddedButtonSet={''};
            schema.DialogStyle='frameless';
            schema.Transient=false;
            schema.ExplicitShow=true;
            schema.IsScrollable=false;
            schema.HideOnClose=true;
        end
    end
end