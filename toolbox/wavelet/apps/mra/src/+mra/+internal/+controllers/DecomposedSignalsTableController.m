

classdef DecomposedSignalsTableController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
UpdateSelectionComplete
DeleteScenarioComplete
PlotSignals
RenameScenarioComplete
    end

    properties(Constant)
        ControllerID="DecomposedSignalsTableController";
    end


    methods(Hidden)
        function this=DecomposedSignalsTableController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"updateselection",'callback',@this.cb_UpdateSelection);
            struct('messageID',"deletedecomposition",'callback',@this.cb_DeleteScenario);
            struct('messageID',"renamedecomposition",'callback',@this.cb_RenameScenario);
            ];
        end


        function cb_UpdateSelection(this,args)

            selectedScenarioID=args.data.selectedScenarioID;
            isSelectionAfterDelete=args.data.isSelectionAfterDelete;
            previouslySelectedScenarioID=args.data.previouslySelectedScenarioID;


            this.Model.updateFrequencyRangesForScenario(selectedScenarioID);


            toolstripData.messageID="setValuesInToolstrip";
            isTimeInfoNeeded=true;
            toolstripData.data=this.Model.getDataForToolstrip(selectedScenarioID,isTimeInfoNeeded);
            this.notify("UpdateSelectionComplete",sigwebappsutils.internal.EventData(toolstripData));



            decompositionSignalIDsToBeRemoved=[];
            if~isSelectionAfterDelete




                decompositionSignalIDsToBeRemoved=this.Model.getShownDecompositionSignalIDsForScenario(previouslySelectedScenarioID);
            end

            decompositionSignalIDsToBeAdded=this.Model.getShownDecompositionSignalIDsForScenario(selectedScenarioID);


            levelSelectionTableData=this.Model.getDataForLevelSelectionTable(selectedScenarioID);
            levelSelectionImportTableData.messageID="levelSelectionTableData";
            levelSelectionImportTableData.data=levelSelectionTableData;
            this.notify("UpdateSelectionComplete",sigwebappsutils.internal.EventData(levelSelectionImportTableData));


            decompositionAxesData.messageID="replaceDecompositionLevels";
            decompositionAxesData.data.signalIDs=decompositionSignalIDsToBeAdded;
            decompositionAxesData.data.signalIDsToBeRemoved=decompositionSignalIDsToBeRemoved;
            decompositionAxesData.data.destroy=false;
            decompositionAxesData.data.create=false;
            decompositionAxesData.data.xLabel=this.Model.getXLabelForAxes();
            this.notify("UpdateSelectionComplete",sigwebappsutils.internal.EventData(decompositionAxesData));


            signalData=this.Model.getSignalData(selectedScenarioID);
            this.notify("PlotSignals",sigwebappsutils.internal.EventData(signalData));


            reconstructionAxesData.messageID="updateReconstructionLineWidth";
            if~isSelectionAfterDelete

                reconstructionAxesData.data.previousReconstructionSignalID=this.Model.getReconstructionSignalIDInScenario(previouslySelectedScenarioID);
            end
            reconstructionAxesData.data.reconstructionSignalID=this.Model.getReconstructionSignalIDInScenario(selectedScenarioID);
            this.notify("UpdateSelectionComplete",sigwebappsutils.internal.EventData(reconstructionAxesData));
        end

        function cb_DeleteScenario(this,args)

            deletedScenarioID=args.data.deletedScenarioID;

            decompositionSignalIDsRemoved=this.Model.deleteScenario(deletedScenarioID);


            decompositionAxesData.messageID="removeDecompositionLevels";
            decompositionAxesData.data.signalIDs=decompositionSignalIDsRemoved;
            decompositionAxesData.data.destroy=true;
            this.notify("DeleteScenarioComplete",sigwebappsutils.internal.EventData(decompositionAxesData));



            tableData.messageID="deleteDecompositionComplete";
            tableData.data=deletedScenarioID;
            this.notify("DeleteScenarioComplete",sigwebappsutils.internal.EventData(tableData));
        end

        function cb_RenameScenario(this,args)

            selectedScenarioID=string(args.data.selectedScenarioID);
            newScenarioName=string(args.data.newScenarioName);
            newScenarioNameStored=newScenarioName;
            allScenarioNames=this.Model.getAllScenariosNames();


            newScenarioName=matlab.lang.makeValidName(newScenarioName);

            newScenarioName=matlab.lang.makeUniqueStrings(newScenarioName,allScenarioNames);


            this.Model.renameScenario(selectedScenarioID,newScenarioName);

            if newScenarioNameStored~=newScenarioName

                updateScenarioNameData.messageID="updateScenarioName";
                updateScenarioNameData.data.rowData=this.Model.getDataForDecompositionSignalsTable(selectedScenarioID);
                this.notify("RenameScenarioComplete",sigwebappsutils.internal.EventData(updateScenarioNameData));
            end


            renameLegendData.messageID="renameLegend";
            renameLegendData.data.legendLabel=newScenarioName;
            renameLegendData.data.signalID=this.Model.getReconstructionSignalIDInScenario(selectedScenarioID);
            this.notify("RenameScenarioComplete",sigwebappsutils.internal.EventData(renameLegendData));


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("RenameScenarioComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end
    end
end