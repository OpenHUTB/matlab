classdef ModalWidget<Simulink.output.utils.internal.BaseWidget



    methods(Access=public)

        function this=ModalWidget(diagnosticData,position,hint,config)
            this=this@Simulink.output.utils.internal.BaseWidget(diagnosticData,position,hint,config);
        end

        function transient=isTransient(this)
            transient=false;
        end

        function dlg=getDialogSchema(this)
            Title='Diagnostics';
            WebKit=false;
            DisableContextMenu=true;
            webbrowser.Type='webbrowser';
            webbrowser.Name='compositeDVWidget';
            webbrowser.Tag='compositeDVWidget';
            webbrowser.Url=this.getUrl();
            webbrowser.WebKit=WebKit;
            webbrowser.EnableZoom=false;
            webbrowser.DisableContextMenu=DisableContextMenu;
            webbrowser.PreferredSize=[450,250];
            dlg.DialogTitle=Title;
            dlg.Items={webbrowser};
            dlg.StandaloneButtonSet={''};
            dlg.EmbeddedButtonSet={''};
            dlg.Sticky=true;
            dlg.ExplicitShow=true;
            dlg.DialogRefresh=1;
            dlg.DialogTag='compositeDVModalWidget';

            dlg.IsScrollable=false;
            dlg.DialogStyle='none';
            dlg.Transient=false;
            dlg.ContentsMargins=[0,0,0,0];

            dlg.CloseMethod='closeCallback';
            dlg.CloseMethodArgs={'%dialog'};
            dlg.CloseMethodArgsDT={'handle'};
        end
    end

    methods(Access=protected)

        function fitToContent(this,height)
            if(~Simulink.output.utils.internal.BaseWidget.debugMode)
                pos=this.DialogHandle.position;
                TitlebarHeight=25;
                this.DialogHandle.position=[pos(1),pos(2),pos(3),height+TitlebarHeight];
            end
        end

    end

end
