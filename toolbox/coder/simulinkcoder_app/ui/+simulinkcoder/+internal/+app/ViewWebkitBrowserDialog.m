







classdef ViewWebkitBrowserDialog<simulinkcoder.internal.app.View
    methods
        function dlgstruct=getDialogSchema(obj,~)
            dlgstruct.DialogTitle=obj.getDialogTitle;
            dlgstruct.CloseCallback='onBrowserClose';
            dlgstruct.CloseArgs={obj};


            if obj.DEBUG
                url=obj.DebugURL;
                item.DisableContextMenu=false;
                item.EnableInspectorOnLoad=true;
            else
                url=obj.URL;
                item.DisableContextMenu=true;
                item.EnableInspectorOnLoad=false;
            end
            item.Url=url;

            item.Type='webbrowser';
            item.WebKit=true;
            item.MinimumSize=[450,300];
            item.Tag='Tag_CoderDataUI';

            dlgstruct.Items={item};
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs='';
            dlgstruct.MinMaxButtons=true;
            buttonSet={''};
            dlgstruct.StandaloneButtonSet=buttonSet;
            dlgstruct.ExplicitShow=true;
            dlgstruct.DispatcherEvents={};
        end
    end
    methods(Access=private)
        function createDlg(obj)
            p=simulinkcoder.internal.app.View.getSetGeometry;
            if~isa(obj.Dlg,'DAStudio.Dialog')
                obj.Dlg=DAStudio.Dialog(obj);
                obj.Dlg.position=p;
            end

            obj.Dlg.showNormal;
            obj.Dlg.show;
            obj.Dlg.position=p;
        end
    end

    methods
        function obj=ViewWebkitBrowserDialog(modelName)
            obj@simulinkcoder.internal.app.View(modelName);
            obj.registerNameChangeCallback;
        end

        function start(obj)
            if isempty(obj.Dlg)
                start@simulinkcoder.internal.app.View(obj);
                obj.createDlg();
            else
                obj.Dlg.show;
            end
        end

        function onBrowserClose(obj)
            onBrowserClose@simulinkcoder.internal.app.View(obj,obj.Dlg.position);
        end
    end
end


