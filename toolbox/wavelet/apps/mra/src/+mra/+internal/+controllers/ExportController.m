

classdef ExportController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
ExportReconstructionSignalComplete
ExportDecompositionSignalsComplete
GenerateMATLABScriptComplete
    end

    properties(Constant)
        ControllerID="ExportController";
    end


    methods(Hidden)
        function this=ExportController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"exportreconstructionsignal",'callback',@this.cb_ExportReconstructionSignal);
            struct('messageID',"exportdecompositionsignals",'callback',@this.cb_ExportDecompositionSignals);
            struct('messageID',"generatematlabscript",'callback',@this.cb_GenerateMATLABScript);
            ];
        end


        function cb_ExportReconstructionSignal(this,args)

            selectedScenarioID=args.data.selectedScenarioID;
            scenarioName=this.Model.getScenarioName(selectedScenarioID);
            checkForOverwrite=args.data.checkForOverwrite;

            doesVariableNameExistInWorkspace=false;
            if checkForOverwrite
                doesVariableNameExistInWorkspace=mra.internal.Utilities.checkForVariableNameInWorkspace(scenarioName);
            end

            if strlength(scenarioName)>namelengthmax

                alertDialogData.messageID="showAlertDialog";
                alertDialogData.data=scenarioName;
                this.notify("ExportReconstructionSignalComplete",sigwebappsutils.internal.EventData(alertDialogData));
            elseif doesVariableNameExistInWorkspace

                confirmationDialogData.messageID="showConfirmationDialogForExportReconstruction";
                confirmationDialogData.data=scenarioName;
                this.notify("ExportReconstructionSignalComplete",sigwebappsutils.internal.EventData(confirmationDialogData));
            else


                reconstructionData=this.Model.getReconstructionDataForScenario(selectedScenarioID);
                assignin('base',scenarioName,reconstructionData);


                statusBarData.messageID="setTextInStatusLabel";
                statusBarData.data=string(getString(message("wavelet_mraapp:mra:reconstructionExported",scenarioName)));
                this.notify("ExportReconstructionSignalComplete",sigwebappsutils.internal.EventData(statusBarData));
            end


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("ExportReconstructionSignalComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end

        function cb_ExportDecompositionSignals(this,args)

            selectedScenarioID=args.data.selectedScenarioID;
            scenarioName=this.Model.getScenarioName(selectedScenarioID);
            checkForOverwrite=args.data.checkForOverwrite;

            variableName=string(scenarioName)+"Decomposition";
            doesVariableNameExistInWorkspace=false;
            if checkForOverwrite
                doesVariableNameExistInWorkspace=mra.internal.Utilities.checkForVariableNameInWorkspace(variableName);
            end

            if strlength(variableName)>namelengthmax

                alertDialogData.messageID="showAlertDialog";
                alertDialogData.data=variableName;
                this.notify("ExportDecompositionSignalsComplete",sigwebappsutils.internal.EventData(alertDialogData));
            elseif doesVariableNameExistInWorkspace

                confirmationDialogData.messageID="showConfirmationDialogForExportDecomposition";
                confirmationDialogData.data=scenarioName;
                this.notify("ExportDecompositionSignalsComplete",sigwebappsutils.internal.EventData(confirmationDialogData));
            else


                decompositionData=this.Model.getDecompositionSignalForScenario(selectedScenarioID);
                assignin('base',variableName,decompositionData);


                statusBarData.messageID="setTextInStatusLabel";
                statusBarData.data=string(getString(message("wavelet_mraapp:mra:decompositionExported",variableName)));
                this.notify("ExportDecompositionSignalsComplete",sigwebappsutils.internal.EventData(statusBarData));
            end


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("ExportDecompositionSignalsComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end

        function cb_GenerateMATLABScript(this,args)

            selectedScenarioID=args.data.selectedScenarioID;
            scenarioName=this.Model.getScenarioName(selectedScenarioID);

            if strlength(scenarioName)>namelengthmax

                alertDialogData.messageID="showAlertDialog";
                alertDialogData.data=scenarioName;
                this.notify("GenerateMATLABScriptComplete",sigwebappsutils.internal.EventData(alertDialogData));
            else
                scriptText=this.Model.generateMATLABScriptText(args.data.selectedScenarioID);

                editorDoc=matlab.desktop.editor.newDocument(scriptText);

                editorDoc.smartIndentContents();

                editorDoc.goToLine(1);
            end

            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("GenerateMATLABScriptComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end
    end
end