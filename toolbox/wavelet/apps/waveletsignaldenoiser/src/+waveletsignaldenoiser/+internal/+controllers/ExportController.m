

classdef ExportController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
ExportDenoisedSignalComplete
GenerateMATLABScriptComplete
    end

    properties(Constant)
        ControllerID="ExportController";
    end


    methods(Hidden)
        function this=ExportController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"exportdenoisedsignal",'callback',@this.cb_ExportDenoisedSignal);
            struct('messageID',"generatematlabscript",'callback',@this.cb_GenerateMATLABScript);
            ];
        end


        function cb_ExportDenoisedSignal(this,args)

            selectedScenarioID=args.data.selectedScenarioID;
            scenarioName=this.Model.getScenarioName(selectedScenarioID);
            checkForOverwrite=args.data.checkForOverwrite;

            doesVariableNameExistInWorkspace=false;
            if checkForOverwrite
                doesVariableNameExistInWorkspace=waveletsignaldenoiser.internal.Utilities.checkForVariableNameInWorkspace(scenarioName);
            end

            if strlength(scenarioName)>namelengthmax

                alertDialogData.messageID="showAlertDialog";
                alertDialogData.data=scenarioName;
                this.notify("ExportDenoisedSignalComplete",sigwebappsutils.internal.EventData(alertDialogData));
            elseif doesVariableNameExistInWorkspace

                confirmationDialogData.messageID="showConfirmationDialogForExportDenoisedSignal";
                confirmationDialogData.data=scenarioName;
                this.notify("ExportDenoisedSignalComplete",sigwebappsutils.internal.EventData(confirmationDialogData));
            else


                denoisedSignalData=this.Model.getDenoisedSignalDataForScenario(selectedScenarioID);
                assignin('base',scenarioName,denoisedSignalData);


                statusBarData.messageID="setTextInStatusLabel";
                statusBarData.data=string(getString(message("wavelet_signaldenoiser:waveletsignaldenoiser:denoisedSignalExported",scenarioName)));
                this.notify("ExportDenoisedSignalComplete",sigwebappsutils.internal.EventData(statusBarData));
            end


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("ExportDenoisedSignalComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end

        function cb_GenerateMATLABScript(this,args)

            selectedScenarioID=args.data.selectedScenarioID;
            scenarioName=this.Model.getScenarioName(selectedScenarioID);

            if strlength(scenarioName)>namelengthmax

                alertDialogData.messageID="showAlertDialog";
                alertDialogData.data=scenarioName;
                this.notify("GenerateMATLABScriptComplete",sigwebappsutils.internal.EventData(alertDialogData));
            else
                scriptText=this.Model.generateMATLABScriptText(selectedScenarioID);


                editorDoc=matlab.desktop.editor.newDocument(scriptText);

                editorDoc.smartIndentContents();

                editorDoc.goToLine(1);
            end

            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("GenerateMATLABScriptComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end
    end
end