

classdef DenoisedSignalsTableController<handle


    properties(Hidden)
Subscriptions
    end

    properties(Access=protected)
Model
    end

    events
UpdateSelectionComplete
PlotSignals
DeleteScenarioComplete
RenameScenarioComplete
    end

    properties(Constant)
        ControllerID="DenoisedSignalsTableController";
    end


    methods(Hidden)
        function this=DenoisedSignalsTableController(model)

            this.Model=model;

            this.Subscriptions=[
            struct('messageID',"updateselection",'callback',@this.cb_UpdateSelection);
            struct('messageID',"deletedenoisedsignal",'callback',@this.cb_DeleteScenario);
            struct('messageID',"renamedenoisedsignal",'callback',@this.cb_RenameScenario);
            ];
        end


        function cb_UpdateSelection(this,args)

            selectedScenarioID=args.data.selectedScenarioID;
            isSelectionAfterDelete=args.data.isSelectionAfterDelete;
            previouslySelectedScenarioID=args.data.previouslySelectedScenarioID;

            toolstripData.messageID="setValuesInToolstrip";
            toolstripData.data=this.Model.getDataForToolstrip(selectedScenarioID);
            toolstripData.data.enableSignalDenoiserTab=false;
            this.notify("UpdateSelectionComplete",sigwebappsutils.internal.EventData(toolstripData));


            coefficientSignalIDsToBeRemoved=[];
            if~isSelectionAfterDelete




                coefficientSignalIDsToBeRemoved=this.Model.getOriginalCoefficientSignalIDsForScenario(previouslySelectedScenarioID);
            end

            coefficientSignalIDsToBeAdded=this.Model.getOriginalCoefficientSignalIDsForScenario(selectedScenarioID);


            currentWaveletParametersTableData.messageID="currentWaveletParametersTableData";
            currentWaveletParametersTableData.data=this.Model.getDataForCurrentWaveletParametersTable(selectedScenarioID);
            this.notify("UpdateSelectionComplete",sigwebappsutils.internal.EventData(currentWaveletParametersTableData));


            coefficientAxesData.messageID="replaceCoefficientsLevels";
            coefficientAxesData.data.signalIDs=coefficientSignalIDsToBeAdded;
            coefficientAxesData.data.signalIDsToBeRemoved=coefficientSignalIDsToBeRemoved;
            coefficientAxesData.data.destroy=false;
            coefficientAxesData.data.create=false;
            this.notify("UpdateSelectionComplete",sigwebappsutils.internal.EventData(coefficientAxesData));


            signalData=this.Model.getSignalData(selectedScenarioID);
            this.notify("PlotSignals",sigwebappsutils.internal.EventData(signalData));


            denoisingAxesData.messageID="updateDenoisingSignalWidth";
            if~isSelectionAfterDelete

                denoisingAxesData.data.previousDenoisingSignalID=this.Model.getDenoisedSignalIDInScenario(previouslySelectedScenarioID);
            end
            denoisingAxesData.data.denoisingSignalID=this.Model.getDenoisedSignalIDInScenario(selectedScenarioID);
            this.notify("UpdateSelectionComplete",sigwebappsutils.internal.EventData(denoisingAxesData));
        end

        function cb_DeleteScenario(this,args)

            deletedScenarioID=args.data.deletedScenarioID;

            coefficientsSignalIDsRemoved=this.Model.deleteScenario(deletedScenarioID);


            coefficientAxesData.messageID="removeCoefficientsLevels";
            coefficientAxesData.data.signalIDs=coefficientsSignalIDsRemoved;
            coefficientAxesData.data.destroy=true;
            this.notify("DeleteScenarioComplete",sigwebappsutils.internal.EventData(coefficientAxesData));



            tableData.messageID="deleteDenoisedSignalComplete";
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
                updateScenarioNameData.data.rowData=this.Model.getDataForDenoisedSignalsTable(selectedScenarioID);
                this.notify("RenameScenarioComplete",sigwebappsutils.internal.EventData(updateScenarioNameData));
            end


            currentWaveletParametersTableData.messageID="currentWaveletParametersTableData";
            currentWaveletParametersTableData.data=this.Model.getDataForCurrentWaveletParametersTable(selectedScenarioID);
            this.notify("RenameScenarioComplete",sigwebappsutils.internal.EventData(currentWaveletParametersTableData));


            renameLegendData.messageID="renameLegend";
            renameLegendData.data.legendLabel=newScenarioName;
            renameLegendData.data.signalID=this.Model.getDenoisedSignalIDInScenario(selectedScenarioID);
            this.notify("RenameScenarioComplete",sigwebappsutils.internal.EventData(renameLegendData));


            busyOverLayData.messageID="hideBusyOverlay";
            this.notify("RenameScenarioComplete",sigwebappsutils.internal.EventData(busyOverLayData));
        end
    end
end