


classdef Web<handle

    properties(Dependent)
Url
    end

    properties
        Title=''
    end

    properties(Hidden)


        HelpArgs={}
        WebKit=false
        WebKitToolBar={}
        position=[100,100,1000,750]
        DisplayIcon=''
        debug=false
    end

    properties(Access=private)

Dlg
WebBrowser
    end

    properties(Access=private)
        PrivateUrl=''
    end

    properties(Access=private,Transient)
        Dirty=true
    end

    methods
        function obj=Web(aUrl,varargin)
            if nargin>0
                obj.Url=aUrl;
                if nargin>1
                    for k=1:2:length(varargin)
                        obj.(varargin{k})=varargin{k+1};
                    end
                end
            end
            if~isempty(obj.Url)
                obj.show;
            end
        end

        function out=get.Url(obj)
            out=obj.PrivateUrl;
        end

        function set.Url(obj,url)
            obj.PrivateUrl=url;
            obj.Dirty=true;
        end

        function dlgstruct=getDialogSchema(obj,~)
            if~isempty(obj.Title)
                title=obj.Title;
            else
                title=obj.Url;
            end
            if~isempty(obj.HelpArgs)
                buttonSet={'OK','Help'};
            else
                buttonSet={'OK'};
            end

            item.Url=obj.Url;
            item.Type='webbrowser';
            item.WebKit=obj.WebKit;
            item.WebKitToolBar={'Search'};

            if obj.debug
                item.EnableInspectorInContextMenu=true;
                item.EnableInspectorOnLoad=true;
            end


            dlgstruct.DefaultOk=false;
            dlgstruct.DialogTitle=title;
            dlgstruct.Items={item};
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs=obj.HelpArgs;
            dlgstruct.MinMaxButtons=true;
            dlgstruct.StandaloneButtonSet=buttonSet;
            dlgstruct.ExplicitShow=true;
            dlgstruct.DispatcherEvents={};
            if~isempty(obj.DisplayIcon)
                dlgstruct.DisplayIcon=obj.DisplayIcon;
            end
        end

        function show(obj)
            if~isempty(obj.Url)
                if~isa(obj.Dlg,'DAStudio.Dialog')
                    obj.Dlg=DAStudio.Dialog(obj);
                    obj.Dlg.position=obj.position;
                elseif obj.Dirty==true
                    obj.Dlg.refresh;
                end

                obj.Dlg.showNormal;
                obj.Dlg.show;
            end
            obj.Dirty=false;
        end

        function close(obj)
            if isa(obj.Dlg,'DAStudio.Dialog')
                obj.Dlg.delete;
            end
            if~isempty(obj.WebBrowser)
                obj.WebBrowser.close;
                obj.WebBrowser=[];
            end
        end
    end
end


