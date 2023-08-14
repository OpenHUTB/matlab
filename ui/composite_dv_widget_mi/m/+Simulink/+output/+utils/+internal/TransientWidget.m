classdef TransientWidget<Simulink.output.utils.internal.BaseWidget



    methods(Access=public)

        function this=TransientWidget(diagnosticData,position,hint,config,moveOnResize)
            this=this@Simulink.output.utils.internal.BaseWidget(diagnosticData,position,hint,config,moveOnResize);

        end

        function transient=isTransient(this)
            transient=true;
        end

        function dlg=getDialogSchema(this)
            main.Type='webbrowser';
            main.EnableZoom=false;
            main.Name='compositeDVWidget';
            main.Tag='compositeDVWidget';
            main.PreferredSize=[450,250];
            main.Url=this.getUrl();
            main.DisableContextMenu=true;

            dlg.DialogTitle='Diagnostics';
            dlg.Items={main};
            dlg.DialogMode='Slim';
            dlg.StandaloneButtonSet={''};
            dlg.EmbeddedButtonSet={''};
            dlg.ExplicitShow=true;
            dlg.DialogTag='compositeDVWidget';
            dlg.DialogRefresh=1;


            dlg.IsScrollable=false;
            dlg.Transient=true;
            dlg.DialogStyle='frameless';

            dlg.CloseMethod='closeCallback';
            dlg.CloseMethodArgs={'%dialog'};
            dlg.CloseMethodArgsDT={'handle'};
        end
    end

    methods(Access=protected)

        function fitToContent(this,height)
            if(~Simulink.output.utils.internal.BaseWidget.debugMode)
                pos=this.DialogHandle.position;
                y=pos(2);
                if(this.MoveOnResize)


                    y=y+250-height;
                end
                this.DialogHandle.position=[pos(1),y,pos(3),height];
            end
        end

    end
end
