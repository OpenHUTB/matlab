classdef ddgHost<handle

    properties
        url;
        title='';
    end

    methods

        function obj=ddgHost(u)
            obj.url=u;
        end

        function dlg=getDialogSchema(h)

            webbrowser.Type='webbrowser';
            webbrowser.Tag='mdomDataWidget';
            webbrowser.WebKit=false;
            webbrowser.Url=h.url;

            dlg.EmbeddedButtonSet={''};
            dlg.DialogTitle=h.title;
            dlg.Items={webbrowser};
            dlg.IsScrollable=0;
        end

    end
end