

classdef ImportController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
WorkspaceBrowser
WSBEventListener
    end

    events
ImportComplete
PlotSignals
OpenImportSignalDialogComplete
CloseImportSignalDialogComplete
WorkspaceBrowserSelectionChanged
    end

    properties(Constant)
        ControllerID="ImportController";
        WorkspaceBrowserChannel='/MRAWorkspaceBrowserChannel'
        Workspace='mra.internal.filteredworkspace.FilteredWorkspace';
    end


    methods(Hidden)
        function this=ImportController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"openimportsignaldialog",'callback',@this.cb_OpenImportSignalDialog);
            struct('messageID',"closeimportsignaldialog",'callback',@this.cb_CloseImportSignalDialog);
            struct('messageID',"import",'callback',@this.cb_Import);
            ];
        end



        function cb_OpenImportSignalDialog(this,args)


            this.createWorkspaceBrowser(args.clientID);
            openDialogData.messageID="showDialog";
            this.notify("OpenImportSignalDialogComplete",sigwebappsutils.internal.EventData(openDialogData));


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("OpenImportSignalDialogComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end

        function cb_CloseImportSignalDialog(this,~)

            delete(this.WorkspaceBrowser)
            closeDialogData.messageID="closeDialog";
            this.notify("CloseImportSignalDialogComplete",sigwebappsutils.internal.EventData(closeDialogData));
        end

        function cb_Import(this,args)

            if args.data.importFromDialog
                selectionIdx=this.getWorkspaceBrowserSelectionRowIndex();
                renderedData=this.getWorkspaceBrowserRenderedData();
                selectionProperties=jsondecode(renderedData{selectionIdx(1,1)});
                variableName=string(selectionProperties.value);
                selectedData=this.getWorkspaceBrowserDatabyName(variableName);
                this.Model.setImportedSignalName(variableName);
                this.Model.setImportedSignalData(selectedData);
            end

            if this.Model.isAppHasSignal()
                decompositionType="modwtmra";
                scenarioID=this.Model.addNewScenario(decompositionType);


                toolstripData.messageID="setValuesInToolstrip";
                isTimeInfoNeeded=true;
                toolstripData.data=this.Model.getDataForToolstrip(scenarioID,isTimeInfoNeeded);
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(toolstripData));


                resetIncludedAndShowStatus=true;
                decompositionSignalIDs=this.Model.createSignalIDs(scenarioID,resetIncludedAndShowStatus);
                signalIDForImportedSignal=this.Model.createSignalIDForImportedSignal();


                decompositionImportTableData.messageID="decompositionTableData";
                decompositionImportTableData.data=this.Model.getDataForDecompositionSignalsTable(scenarioID);
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(decompositionImportTableData));


                levelSelectionTableFrequencyColumnHeaderData.messageID="updateFrequencyColumnHeader";
                levelSelectionTableFrequencyColumnHeaderData.data=this.Model.getFrequencyColumnLabel();
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(levelSelectionTableFrequencyColumnHeaderData));


                levelSelectionTableData=this.Model.getDataForLevelSelectionTable(scenarioID);
                levelSelectionImportTableData.messageID="levelSelectionTableData";
                levelSelectionImportTableData.data=levelSelectionTableData;
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(levelSelectionImportTableData));


                decompositionAxesData.messageID="addDecompositionLevels";
                decompositionAxesData.data=struct;
                decompositionAxesData.data.signalIDs=decompositionSignalIDs;
                decompositionAxesData.data.yLabels=levelSelectionTableData(:,2);
                xLabel=this.Model.getXLabelForAxes();
                decompositionAxesData.data.xLabel=xLabel;
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(decompositionAxesData));


                reconstructionAxesData.messageID="addReconstruction";
                reconstructionAxesData.data=struct;
                reconstructionAxesData.data.signalID=signalIDForImportedSignal;
                reconstructionAxesData.data.xLabel=xLabel;
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(reconstructionAxesData));


                signalData=this.Model.getSignalData(scenarioID);
                this.notify("PlotSignals",sigwebappsutils.internal.EventData(signalData));
            end


            if args.data.importFromDialog
                this.cb_CloseImportSignalDialog();
            end

            if~this.Model.isAppHasSignal()


                busyOverLayData.messageID="hideBusyOverlay";
                this.notify("ImportComplete",sigwebappsutils.internal.EventData(busyOverLayData));
            end
        end
    end


    methods(Hidden)
        function createWorkspaceBrowser(this,clientID)
            workspaceChannel=[this.WorkspaceBrowserChannel,clientID];
            this.WorkspaceBrowser=...
            internal.matlab.desktop_workspacebrowser.MF0ViewModelWorkspaceBrowserFactory.createWorkspaceBrowser(this.Workspace,workspaceChannel,'UIWorkspaceBrowser');
            this.WorkspaceBrowser.Documents.ViewModel.setColumnVisible('Value',false);
        end

        function selectionIndices=getWorkspaceBrowserSelectionRowIndex(this)
            selectionIndices=this.WorkspaceBrowser.Documents.ViewModel.getSelection{1};
        end

        function data=getWorkspaceBrowserRenderedData(this)
            workspaceBrowserSize=this.WorkspaceBrowser.Documents.ViewModel.DataModel.CachedSize(1);
            data=this.WorkspaceBrowser.Documents.ViewModel.getRenderedData(1,workspaceBrowserSize,1,3);
        end

        function data=getWorkspaceBrowserDatabyName(this,variableName)
            data=this.WorkspaceBrowser.Documents.ViewModel.DataModel.Workspace.(variableName);
        end
    end
end