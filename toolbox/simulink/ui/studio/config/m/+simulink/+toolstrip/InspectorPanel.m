


classdef(Hidden)InspectorPanel<handle
    properties(Access=private)
        Title='ToolStrip Inspector';
        Url='';
        ToolbarOptions={};
        Geometry=[];
        EnableInspectorInContextMenu=true;
        EnableInspectorOnLoad=false;
        Debug=false;
        ClearCache=true;
        EnableJsOnClipboard=true;
        WebKit=false;
        Tag='ToolStripInspector';
        Html='';
        HomeUrl='';
        PageNotFoundUrl='';
        Studio;
        ToolStrip;
        BaseUrl='/toolbox/dig_web/dig/inspector.html';
        Component;
        DockPosition='Bottom';
        DockOption='Tabbed';
        Subscription;
        BaseChannel='/dig/inspector/';
        OutChannel='';
        InChannel='';
    end

    methods
        function this=InspectorPanel(studio)
            if nargin>0
                this.Studio=studio;
                this.ToolStrip=this.Studio.getToolStrip;
                this.OutChannel=[this.BaseChannel,'out/',this.ToolStrip.Id];
                this.InChannel=[this.BaseChannel,'in/',this.ToolStrip.Id];
                this.Url=connector.applyNonce(connector.getBaseUrl([this.BaseUrl,'?viewId=',this.ToolStrip.Id]));
                this.show();
            end
        end

        function receive(this,varargin)
            message.publish(this.InChannel,varargin{1}.data);
        end

        function show(this)
            if(~this.isValid())
                this.ToolStrip.ShowWidgetInfoAsToolTip=true;
                this.Component=DAStudio.openEmbeddedDDGForSource(this.Studio,this,this.Tag,this.Title,this.DockPosition,this.DockOption);
                this.Component.DestroyOnHide=1;

                this.Subscription=message.subscribe(this.OutChannel,@this.receive);
            end
        end

        function hide(this)
            if(this.isValid())
                this.ToolStrip.ShowWidgetInfoAsToolTip=false;

                message.unsubscribe(this.Subscription);

                this.Studio.destroyComponent(this.Component);
                this.Component=[];
            end
        end

        function ret=isValid(this)
            ret=~isempty(this.Component)&&isvalid(this.Component);
        end

        function dlg=getDialogSchema(h)
            webbrowser.Type='webbrowser';
            webbrowser.Tag='DDGWebBrowser';
            webbrowser.Url=h.Url;
            webbrowser.HTML=h.Html;
            webbrowser.WebKit=h.WebKit;
            webbrowser.WebKitToolBar=h.ToolbarOptions;
            webbrowser.HomeURL=h.HomeUrl;
            webbrowser.PageNotFoundUrl=h.PageNotFoundUrl;
            webbrowser.EnableInspectorInContextMenu=h.EnableInspectorInContextMenu;
            webbrowser.EnableInspectorOnLoad=h.EnableInspectorOnLoad;
            webbrowser.ClearCache=h.ClearCache;
            webbrowser.Debug=h.Debug;
            webbrowser.EnableJsOnClipboard=h.EnableJsOnClipboard;

            dlg.DialogTitle='';
            dlg.DialogTag=h.Tag;
            dlg.Items={webbrowser};
            dlg.StandaloneButtonSet={''};
            dlg.EmbeddedButtonSet={''};

            if(~isempty(h.Geometry))
                dlg.Geometry=h.Geometry;
            end
        end

        function delete(this)
            this.hide();
        end
    end
end