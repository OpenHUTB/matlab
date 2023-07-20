classdef CoSimSignalCompensationDialog<handle
    properties
        backgroundColor=[255,255,223];
        block='';
        port='';
        cbinfo=0;
        inputPortsSource;
        outputPortsSource;
        dialog;
    end

    methods(Access=public)
        function this=CoSimSignalCompensationDialog(cbinfo,blk,port)
            this.cbinfo=cbinfo;
            this.block=blk;
            this.port=port;

            this.inputPortsSource=Simulink.cosimservice.internal.CoSimSignalSpreadSheetSource(this,blk,'input');
            this.outputPortsSource=Simulink.cosimservice.internal.CoSimSignalSpreadSheetSource(this,blk,'output');
        end

        config=getInportCoSimSignalConfiguration(obj,port)
        [status,errmsg]=coSimPreApplyCallback(obj,dlg)
        openCoSimSignalCompensationAdvancedDialog(this)

        function show(this,dlg)
            this.dialog=dlg;

            width=max(550,dlg.position(3));
            height=max(600,dlg.position(4));
            if~isempty(this.port)
                dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'Port',this.port.Handle);
            else
                dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'Block',get_param(this.block,'Handle'));
            end
            dlg.show();
        end
    end

    methods(Static)
        function create()


        end

        function opendlg(src)
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
        end
    end
end
