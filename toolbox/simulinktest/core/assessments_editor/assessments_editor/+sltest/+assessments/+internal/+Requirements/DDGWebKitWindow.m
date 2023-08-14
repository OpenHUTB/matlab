classdef DDGWebKitWindow<handle

    properties(Access=private)
        title;
        tag;
        geometry;
        browser;
        closeCallback;
    end

    methods(Access=private)
        function self=DDGWebKitWindow(title,url,varargin)
            p=inputParser();
            p.FunctionName='sltest.assessments.internal.Requirements.DDGWebKitWindow';
            p.addRequired('title',@ischar);
            p.addRequired('url',@ischar);
            p.addParameter('tag','',@ischar);
            p.addParameter('geometry',[],@(x)isnumeric(x)&&isequal(size(x),[1,4]))
            p.addParameter('inspector',false,@islogical);
            p.addParameter('contextmenu',false,@islogical);
            p.addParameter('nocache',false,@islogical);
            p.addParameter('closeCallback',[],@(x)validateattributes(x,{'function_handle'},{'scalar'}));
            p.parse(title,url,varargin{:});

            self.title=p.Results.title;
            self.tag=p.Results.tag;
            self.geometry=p.Results.geometry;
            self.browser.Type='webbrowser';

            self.browser.Url=p.Results.url;
            self.browser.EnableJsOnClipboard=true;
            self.browser.EnableInspectorInContextMenu=p.Results.inspector;
            self.browser.DisableContextMenu=~p.Results.inspector&&~p.Results.contextmenu;
            self.browser.ClearCache=p.Results.nocache;
            self.closeCallback=p.Results.closeCallback;
        end
    end

    methods
        function schema=getDialogSchema(self)
            schema.DialogTitle=self.title;
            if~isempty(self.tag)
                schema.DialogTag=self.tag;
            end
            if~isempty(self.geometry)
                schema.Geometry=self.geometry;
            end
            schema.CloseMethod='handleClose';
            schema.Items={self.browser};
            schema.StandaloneButtonSet={''};
            schema.IsScrollable=false;
            schema.DispatcherEvents={};
            schema.IgnoreESCClose=true;
            schema.MinMaxButtons=true;
        end

        function handleClose(self)
            if~isempty(self.closeCallback)
                self.closeCallback()
            end
        end
    end

    methods(Static)
        function dlg=create(title,url,varargin)
            dlg=DAStudio.Dialog(sltest.assessments.internal.Requirements.DDGWebKitWindow(title,url,varargin{:}));
        end
    end
end
