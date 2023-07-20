classdef ExportController<handle




    properties(Access=private)
Model
    end

    events

UpdateStatusBar
    end

    methods(Hidden)

        function this=ExportController(model)
            this.Model=model;
            dialog=wavelettfanalyzer.internal.Dialog.setGetDialog();
            addlistener(dialog,"ExportScalogramOverwriteConfirmed",@(~,~)this.cb_ExportScalogram(false));
        end


        function cb_ExportScalogram(this,confirm)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            name=this.Model.getCurrentSignalName();
            structName=name+"_scalogram";

            export=true;
            if strlength(structName)>namelengthmax
                this.alertInvalidVariableName(structName);
                export=false;
            end

            exists=this.checkVariableExists(structName);
            if export&&confirm&&exists
                this.confirmOverwriteData(structName);
            elseif export
                if this.Model.getUseBackgroundPool()
                    bp=backgroundPool;
                    bkgpexport=parfeval(bp,@()this.Model.getExportData(),1);
                    afterEach(bkgpexport,@(varargin)this.getExportDataComplete(structName,varargin{:}),0);
                else
                    exportData=this.Model.getExportData();
                    this.getExportDataComplete(structName,exportData);
                end
            else
                busyOverlay.hide();
            end
        end

        function cb_GenerateScript(this)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.show();
            name=this.Model.getCurrentSignalName();
            if this.Model.getIsTimetable(name)
                splitStr=split(name,"_");
                name=splitStr(1);
            end

            generate=true;
            if strlength(name)>namelengthmax
                this.alertInvalidVariableName(name);
                generate=false;
            end

            if generate
                scriptText=this.Model.getScriptString();
                editorDoc=matlab.desktop.editor.newDocument(scriptText);
                editorDoc.smartIndentContents();
                editorDoc.goToLine(1);

                updateStatusBarEventData.status=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:generateScript",this.Model.getCurrentSignalName())));
                this.notify("UpdateStatusBar",wavelettfanalyzer.internal.EventData(updateStatusBarEventData));
            end
            busyOverlay.hide();
        end
    end

    methods(Hidden)

        function exists=checkVariableExists(this,name)
            result=evalin("base","whos('"+name+"')");
            exists=~isempty(result);
        end

        function alertInvalidVariableName(this,name)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
            dialog=wavelettfanalyzer.internal.Dialog.setGetDialog();
            dialogTitle=string(getString(message("wavelet_tfanalyzer:dialog:exportDataNameTooLongDialogTitle")));
            dialogMessage=string(getString(message("wavelet_tfanalyzer:dialog:exportDataNameTooLongDialogMessage",name)));
            dialog.showAlert(dialogTitle,dialogMessage);
            busyOverlay.show();
        end

        function confirmOverwriteData(this,name)
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
            dialog=wavelettfanalyzer.internal.Dialog.setGetDialog();
            dialogTitle=string(getString(message("wavelet_tfanalyzer:dialog:exportDataVariableExistsDialogTitle")));
            dialogMessage=string(getString(message("wavelet_tfanalyzer:dialog:exportDataVariableExistsDialogMessage",name)));
            dialog.showConfirm("exportScalogramOverwrite",dialogTitle,dialogMessage);
        end

        function getExportDataComplete(this,structName,varargin)
            exportData=varargin{1};
            assignin("base",structName,exportData);
            updateStatusBarEventData.status=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:exportScalogram",structName)));
            this.notify("UpdateStatusBar",wavelettfanalyzer.internal.EventData(updateStatusBarEventData));
            busyOverlay=wavelettfanalyzer.internal.BusyOverlay.setGetBusyOverlay();
            busyOverlay.hide();
        end
    end

end
