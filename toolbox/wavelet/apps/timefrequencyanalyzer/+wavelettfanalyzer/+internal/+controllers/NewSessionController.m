classdef NewSessionController<handle




    properties(Access=private)
Model
    end

    events

ClearAxes

ClearStatusBar

ClearTable

ClearToolstrip
    end

    methods(Hidden)

        function this=NewSessionController(model)
            this.Model=model;
            dialog=wavelettfanalyzer.internal.Dialog.setGetDialog();
            addlistener(dialog,"StartNewSessionConfirmed",@(~,~)this.cb_StartNewSession(false));
        end


        function cb_StartNewSession(this,confirm)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            if confirm
                this.confirmStartNewSession();
            else
                this.Model.reset();
                this.notify("ClearAxes");
                this.notify("ClearStatusBar");
                this.notify("ClearTable");
                this.notify("ClearToolstrip");
                busyOverlay.hide();
            end
        end
    end

    methods(Access=protected)

        function confirmStartNewSession(this)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
            dialog=wavelettfanalyzer.internal.Dialog.setGetDialog();
            dialogTitle=string(getString(message("wavelet_tfanalyzer:dialog:newSessionDialogTitle")));
            dialogMessage=string(getString(message("wavelet_tfanalyzer:dialog:newSessionDialogMessage")));
            dialog.showConfirm("startNewSession",dialogTitle,dialogMessage);
        end
    end

end
